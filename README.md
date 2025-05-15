# Huver

Web service for view static html files.
Like some action's logs.

## Build

```bash
docker build -t huver .
```

## Run

```bash
docker run -d -v ./data:/data:ro -p 8080:80 --name huver huver
```
