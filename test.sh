#!/bin/bash

echo "Livy spark-submit: Spark Pi "
docker exec -it livy spark-submit \
                                        --deploy-mode client \
                                        --driver-memory 1g \
                                        --executor-memory 1g \
                                        --executor-cores 1 \
                                        --class org.apache.spark.examples.SparkPi \
                                        /opt/spark/examples/jars/spark-examples_2.12-3.5.5.jar



echo "Livy Rest: Spark Pi "
curl -H "Content-Type: application/json" http://localhost:8998/batches -X POST --data '{
  "name" : "SparkPi",
  "className" :  "org.apache.spark.examples.SparkPi",
  "file"  : "local:/opt/spark/examples/jars/spark-examples_2.12-3.5.5.jar"
}'


echo "Livy Py Job"
curl -H "Content-Type: application/json" http://localhost:8998/batches -X POST --data '{
  "name" : "PySpark",
  "file"  : "local:/jobs/spark_job.py"
}' 


