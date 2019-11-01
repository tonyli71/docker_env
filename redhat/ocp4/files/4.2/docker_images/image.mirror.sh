#!/usr/bin/env bash

set -e
set -x

/bin/rm -f pull.image.failed.list pull.image.ok.list

# export OCP_RELEASE=${BUILDNUMBER}
# export LOCAL_REG='registry.redhat.ren'
# export LOCAL_REPO='ocp4/openshift4'
# export UPSTREAM_REPO='openshift-release-dev'
# export LOCAL_SECRET_JSON="pull-secret.json"
# export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=${LOCAL_REG}/${LOCAL_REPO}:${OCP_RELEASE}
# export RELEASE_NAME="ocp-release"

mirror_docker_image(){

    docker_image=$1
    echo $docker_image

    if [[ "$docker_image" =~ ^$ ]] || [[ "$docker_image" =~ ^[[:space:]]+$ ]] || [[ "$docker_image" =~ \#[:print:]*  ]]; then
        # echo "this is comments"
        return;
    elif [[ $docker_image =~ ^.*\.(io|com|org)/.*@sha256:.* ]]; then
        # echo "io, com, org with tag: $docker_image"
        image_part=$(echo $docker_image | sed -r 's/^.*\.(io|com|org)//')
        local_image="${LOCAL_REG}${image_part}"
        image_part=$(echo $image_part | sed -r 's/@sha256:.*$//')
        local_image_url="${LOCAL_REG}${image_part}"

        yaml_image=$(echo $docker_image | sed -r 's/@sha256:.*$//')
        yaml_local_image=$local_image_url
        # echo $image_url
    elif [[ $docker_image =~ ^.*\.(io|com|org)/.*:.* ]]; then
        # echo "io, com, org with tag: $docker_image"
        image_part=$(echo $docker_image | sed -r 's/^.*\.(io|com|org)//')
        local_image="${LOCAL_REG}${image_part}"
        local_image_url="${LOCAL_REG}${image_part}"

        yaml_image=$(echo $docker_image | sed -r 's/:.*$//')
        yaml_local_image=$(echo $local_image_url | sed -r 's/:.*$//')
        # echo $image_url
    elif [[ $docker_image =~ ^.*\.(io|com|org)/[^:]*  ]]; then
        # echo "io, com, org without tag: $docker_image"
        image_part=$(echo $docker_image | sed -r 's/^.*\.(io|com|org)//')
        local_image="${LOCAL_REG}${image_part}:latest"
        local_image_url="${LOCAL_REG}${image_part}:latest"
        # echo $image_url

        docker_image+=":latest"

        yaml_image=$docker_image
        yaml_local_image="${LOCAL_REG}${image_part}"
    elif [[ $docker_image =~ ^.*/.*@sha256:.* ]]; then
        # echo "docker with tag: $docker_image"
        NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        # cksum <<< 'b79a5903075388c64a2215540398ae5bcf6b77b7fdd84c66c9eb62762aa4aaef' | cut -f 1 -d ' '
        local_image="${LOCAL_REG}/${docker_image}"
        image_part=$(echo $docker_image | sed -r 's/@sha256:.*$//')
        local_image_url="${LOCAL_REG}/${image_part}:${NEW_UUID}"
        # echo $image_url
        yaml_image=$docker_image
        yaml_local_image=$local_image_url
    elif [[ $docker_image =~ ^.*/.*:.* ]]; then
        # echo "docker with tag: $docker_image"
        local_image="${LOCAL_REG}/${docker_image}"
        local_image_url="${LOCAL_REG}/${docker_image}"
        # echo $image_url
        yaml_image=$docker_image
        yaml_local_image=local_image_url

    elif [[ $docker_image =~ ^.*/[^:]* ]]; then
        # echo "docker without tag: $docker_image"
        local_image="${LOCAL_REG}/${docker_image}:latest"
        local_image_url="${LOCAL_REG}/${docker_image}:latest"

        # echo $image_url
        docker_image+=":latest"

        yaml_image=$docker_image
        yaml_local_image="$local_image_url"
    fi

    if oc image mirror $docker_image $local_image_url; then
        echo -e "${docker_image}" >> pull.image.ok.list
        echo -e "${yaml_image}\t${yaml_local_image}" >> yaml.image.ok.list
    else
        echo "$docker_image" >> pull.image.failed.list
    fi

}

while read -r line; do

    mirror_docker_image $line

done < install.image.list

while read -r line; do

    delimiter="\t"
    declare -a array=($(echo $line | tr "$delimiter" " "))
    url=${array[0]}

    mirror_docker_image $url

done < operator.image.list

cat yaml.image.ok.list | sort | uniq > yaml.image.ok.list.uniq


