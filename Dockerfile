
# Building a multistage dockerfile and that's why we use "as"
# building a code doesn't need gradle installed thaat's why jdk image is only needed

FROM openjdk:11 as base 
WORKDIR /app
#FIRST dot current directory to the other dot (work directory)
COPY . .
RUN chmod +x gradlew
RUN ./gradlew build

FROM tomcat:9
WORKDIR webapps
COPY --from=base /app/build/libs/sampleWeb-0.0.1-SNAPSHOT.war .
RUN rm -rf ROOT && mv sampleWeb-0.0.1-SNAPSHOT.war ROOT.war
