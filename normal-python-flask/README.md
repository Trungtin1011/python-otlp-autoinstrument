## Use Docker to Deploy Flask App

```
docker build -t flask-demo-app ./build/
```

- Now we need to run the container from image. Run this command:
```
docker run -it -p 5000:5000 flask-demo-app:latest
```
- You should be able to open the flask app in browser using:
```
http://localhost:5000
```
