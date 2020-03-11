package main

import (
	"context"
	"fmt"
	"log"
	"sort"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/rds"
)

type EventData struct {
	S3BucketName       string `json:"s3BucketName"`
	S3BucketPrefix     string `json:"s3BucketPrefix"`
	IamRoleArn         string `json:"iamRoleArn"`
	KmsKeyId           string `json:"kmsKeyId"`
	Region             string `json:"region"`
	InstanceIdentifier string `json:"instanceIdentifier"`
}

func getRdsClient(region string) *rds.RDS {
	awsSession, err := session.NewSession(&aws.Config{
		Region: aws.String(region)},
	)

	if err != nil {
		log.Fatalf("Unable to get RdsClient: %v", err)
	}

	return rds.New(awsSession)
}

func exportSnapshot(rdsClient *rds.RDS, event EventData) string {
	snapshot := findLastSnapshot(rdsClient, event.InstanceIdentifier)

	input := rds.StartExportTaskInput{
		ExportTaskIdentifier: generateIdentifierName(snapshot.DBSnapshotIdentifier),
		SourceArn:            snapshot.DBSnapshotArn,
		IamRoleArn:           &event.IamRoleArn,
		KmsKeyId:             &event.KmsKeyId,
		S3BucketName:         &event.S3BucketName,
		S3Prefix:             &event.S3BucketPrefix,
	}

	log.Print(fmt.Sprintf("StartExportTaskInput: %+v\n", input))

	output, err := rdsClient.StartExportTask(&input)

	if err != nil {
		log.Fatalf("Error on StartExportTask: %v", err)
	}

	return fmt.Sprintf("%+v\n", output)

}

func generateIdentifierName(snapshotIdentifier *string) *string {
	hr, min, _ := time.Now().Clock()

	return aws.String(fmt.Sprintf("%s-export-%d-%d", (*snapshotIdentifier)[4:], hr, min))
}

func findLastSnapshot(rdsClient *rds.RDS, instanceIdentifier string) *rds.DBSnapshot {
	input := rds.DescribeDBSnapshotsInput{
		SnapshotType:         aws.String("automated"),
		DBInstanceIdentifier: &instanceIdentifier,
	}

	result, err := rdsClient.DescribeDBSnapshots(&input)
	if err != nil {
		log.Fatalf("Unable to DescribeDBSnapshots: %v", err)
	}

	snapshots := result.DBSnapshots

	if len(snapshots) == 0 {
		log.Fatal("Snapshot not found!")
	}

	sort.Slice(snapshots, func(i, j int) bool {
		return snapshots[i].SnapshotCreateTime.Unix() > snapshots[j].SnapshotCreateTime.Unix()
	})

	return snapshots[0]
}

func HandleRequest(ctx context.Context, event EventData) (string, error) {
	log.Print(fmt.Sprintf("Receive event: %+v\n", event))
	rdsClient := getRdsClient(event.Region)

	return exportSnapshot(rdsClient, event), nil
}

func main() {
	lambda.Start(HandleRequest)
}
