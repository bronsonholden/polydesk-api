# Polydesk

## Deployment

Polydesk is deployed using a CI/CD pipeline built using AWS CodeCommit,
CodeBuild, and CodePipeline. The API server is hosted in an ElasticBeanstalk
high-availability environment. When code is pushed to the master branch in
CodeCommit, a pipeline is triggered in CodePipeline that:

1. Builds the API server image, applies the `latest` tag and pushes it to ECR
2. Migrates the database (in a CodeBuild project)
3. Builds an ElasticBeanstalk deployment artifact (stored in S3)
4. Deploys to ElasticBeanstalk

Migration in the deployment pipeline isn't a concern if changes are managed
correctly. Columns should never be dropped if they are referenced by any
code in the currently-deployed application version (or any workers),
constraints should never be applied to columns that don't already satisfy them
(using supporting migrations and/or temporary application code to ensure
this), avoid anything that would lock your tables against writes, etc. And
for cases where a migration isn't appropriate to run in the deployment
pipeline, it can be run from a separate environment before the code is
pushed to CodeCommit, so the migration becomes a no-op stage.

## Local environment

To run locally, ensure you have the following either installed locally or
running in a Docker container (with appropriate ports exposed):

1. PostgreSQL
2. Redis

Create/migrate the database for your environment:

```
rake db:create db:migrate
```

Run the server:

```
rails s
```
