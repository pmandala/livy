# Livy Setup


## Prerequisites

- Download JDK jdk-17.0.14_linux-x64_bin.rpm
- Download [Spark 3.5.5] (https://archive.apache.org/dist/spark/spark-3.5.5/spark-3.5.5-bin-hadoop3.tgz) 


### Build the spark images

```
make build
```

### Start the spark cluster with single worker node

```
make up

```

### Stop the spark cluster

```
make down
```

### Livy UI

```
http://localhost:8998/ui
```


### Livy  Shell





