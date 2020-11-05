# Serverless Todo in PHP

This repository is an example of deploying PHP web applications on AWS Lambda. 
This example uses Custom PHP runtime for deploying lambda function.
We can deploy __Laravel__ or __Codeigniter__ applications by simply putting their source code to `php/src` directory.
By Creating API-Gateway in AWS, We can check our running web applications.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)

## Quick Start

1) Clone the repo

```
git clone https://github.com/canopas/serverless-php.git
cd serverless-php
```

2) Configure your AWS credentials, region and IAM role in `php/deploy.sh`

3) Run DockerFile To deploy Lambda function.

```
docker build .
```

## Platforms Supports

As this repo support integration for both Laravel and CodeIgniter, There are some prerequisites before deploying lambda functions for each type of application.

- Set platforms in `php/runtime.php` according your need.

- Put source code in `php/src` directory.

- AWS cannot write logs or cache in Lambda function's directory, we have to change configuration of those in their config files.

- If you are using codeigniter, Update `$app->run()` in `public/index.php` to
    ````
    $response = $app->run();
    ````
  
## Explanation

- #### DockerFile
     - Used two docker image, 
          - First for compile php binary, that binary will used by further docker image.
          - Second for generating zip files for runtime and functions and deploying Lambda function.
     - `runtime.zip` contains bootstarp, runtime.php, php-cgi, vendor and extra-libraries. It will deploy in Lamda's `opt` directory.
     - `src.zip` contains src.
      
- #### bootstarp & runtime.php
     - Bootstrap is entrypoint for custom PHP runtime. It executes `runtime.php`.
    
     - `runtime.php` contains code to handle php on AWS Lambda with the reference of [this example](https://aws.amazon.com/blogs/apn/aws-lambda-custom-runtime-for-php-a-practical-example/).
     
     - It every time calls index.php to serve incoming requests.
       
- #### php-cgi
     - It is the binary file for executing lambda function.We are using php-cgi because our goal is to deploy serverless php web applications.
    
- #### vendor
     - It contains `guzzlehttp/guzzle` package dependency for serving http requests.
     
- #### extra-Libraries
     - AmazonLinux2 does not provide all shared libraries, those are required by php execution. We can encounter error when running Lambda function.
        ````
        error while loading shared libraries: libcrypt.so.1: cannot open shared object file: No such file or directory.
        ````
        
     - We have to add those libraries manually.
     
     - I have added some of those here, and you can add others too by following instructions.
    
         - Make a directory name `extra-libraries`
         - Copy all required libraries from Amazon Linux to `extra-libraries` by using following steps :
              - Run amazon Linux docker instance using `docker run --rm -it -v :/opt:rw,delegated amazonlinux:latest`
              - Then in docker instance make directory using `mkdir deps`
              - Copy all required libraries from lib64 to deps directory using `cp -f lib64/libcrypt.so.1 deps` (Taken libcrypt.so.1 for reference)
              - Then open another terminal window and move all library files to local extra-libs using 
                `docker cp <DOCKER_CONTAINER_ID>:/deps/ . && mv deps/* ./extra-libraries`
                
     - Updated `LD_LIBRARY_PATH` in bootstrap, to point this extra-libraries in AWS lambda runtime.

- #### src
     - It contains `index.php` file for serving our php web applications. 
