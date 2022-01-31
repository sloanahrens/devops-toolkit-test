#!/bin/bash


export POSTGRES_HOST=postgres-primary.db-${DEPLOYMENT_NAME}.net
export POSTGRES_PORT=5432
export POSTGRES_USER=${PROJECT_NAME}
export POSTGRES_DB=${PROJECT_NAME}_db
export POSTGRES_VERSION=12.8
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD-'newborn-invasive-persona-maiden-asbestos-optic-croci-moralist-defat-juniper'}