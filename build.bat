: Script to build lambda

: install lambda build zip
set GO111MODULE=on
go.exe get -u github.com/aws/aws-lambda-go/cmd/build-lambda-zip

: build lamba
set GOOS=linux
set GOARCH=amd64
set CGO_ENABLED=0
go build -o lambda-function main.go
%USERPROFILE%\Go\bin\build-lambda-zip.exe --output lambda-function.zip lambda-function
del lambda-function