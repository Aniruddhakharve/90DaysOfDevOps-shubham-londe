#!/bin/bash

set -e

mkdir /tmp/devops-test || echo "Directory alrady exists"

cd /tmp/devops-test || echo "Failed to enter the Directory"

touch example.txt || echo "File creation failed"

echo "script Completed successfully"
