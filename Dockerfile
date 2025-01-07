variables:
    DOCKER_IMAGE: ${REGISTRY_URL}/${REGISTRY_PROJECT}/${CI_PROJECT_NAME}:${CI_COMMIT_TAG}_${CI_COMMIT_SHORT_SHA}
    DOCKER_CONTAINER: ${CI_PROJECT_NAME}
stages:
    - build
    - deploy
    - checklog
build:
    variables:
        GIT_STRATEGY: clone
    stage: build
    before_script:
	- docker login ${REGISTRY_URL} -u ${REGISTRYa_USER} -p ${REGISTRY_PASSWORD}
    script:
	- docker build -t $DOCKER_IMAGE .
	- docker push  $DOCKER_IMAGE
    tags:
        - lab-server
    only:
        - tags
deploy:
    variables:
        GIT_STRATEGY: none
    when: manual
    stage: deploy

    before_script:
	- docker login ${REGISTRY_URL} -u ${REGISTRYa_USER} -p ${REGISTRY_PASSWORD}
    script:
	- docker pull $DOCKER_IMAGE
	- docker rm -f $DOCKER_CONTAINER
	- docker run --name $DOCKER_CONTAINER -dp 8080:8080 $DOCKER_IMAGE
    tags:
        - lab-server
    only:
        - tags
checklog:
    variables:
        GIT_STRATEGY: none
    when: manual
    stage: checklog
    script:
        - sleep:20
	- docker logs $DOCKER_CONTAINER
    tags:
        - lab-server
    only:
        - tags

