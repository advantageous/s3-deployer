# S3/CloudFront Automation for CI/CD
## Deployment
Deploy updated site to s3 and invalidate CloudFront cache.
#### Usage:

    deploy.sh [-h] [-e env-name]

#### Options:
* -h: Displays this information.
* -e: Deployment environment. If not set the branch will determine this.

## Configuration
This script requires a .deployrc configuration file. This file should be placed in the directory which the script is run. This is typically the root of your project beside your .travis.yml or Jenkinsfile.
You may also specify environment-specific parameters in their own .deployrc.env_name files.  For example you can create a .deployrc.prod and its values will override the main one when deploying to a environment named prod.

It is important note that the name, region, and cluster can not be changed once the service is created.

The following parameters must be contained either in the .deployrc file or the environment-specific rc file:

    remote="s3://mysite.com"
    distribution=distribution-id

The following parameters are optional and will default to these values:

    local=. # Site root defaults to project root (working dir after checkout)
    
## Travis and Jenkins Integration
The deploy script is aware of Travis and Jenkins ENV vars to give it clues on how to automatically deploy.
This is based off of the deployment schema that I use on all my other projects.

On my team, developers work in feature branches and merge to a branch called "integration" to integrate and test their
changes with the team. Integration commits/merges are automatically deployed to the integration environment.  Every
merge requires a version bump in the gradle build file (for Java/Kotlin projects) or the package.json (for node.js).
I use these versions to tag the docker images and then it's always easy to tell what is in any env, what feature train
it is on, etc.
