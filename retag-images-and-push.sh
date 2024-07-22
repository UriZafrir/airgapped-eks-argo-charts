#!/bin/bash
REGISTRY=<your-private-registry>
IMAGE_LIST_FILE="images.txt"

# Check if the image list file exists
if [ ! -f "$IMAGE_LIST_FILE" ]; then
  echo "Image list file ($IMAGE_LIST_FILE) not found!"
  exit 1
fi

# Check if the file ends with a newline and add it if not
if [ -n "$(tail -c 1 "$IMAGE_LIST_FILE")" ]; then
  echo >> "$IMAGE_LIST_FILE"
fi

while read line; do
    echo "Processing image: $line"

    # Extract repository path after the first slash
    REPOSITORY=${line#*/}

    # Pull the image
    docker pull "$line"

    # Get IMAGE_ID and TAG of the pulled image
    IMAGE_INFO=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep "$line")
    echo $IMAGE_INFO
    IMAGE_ID=$(echo "$IMAGE_INFO" | awk '{print $2}')
    echo "Image ID: $IMAGE_ID"
    TAG=$(echo "$IMAGE_INFO" | awk -F: '{print $2}' | awk '{print $1}')
    echo "Tag: $TAG"

    # Tag the image with the new registry
    docker tag "$IMAGE_ID" "$REGISTRY/$REPOSITORY:$TAG"
    docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep "$REGISTRY"

    # Push the tagged image to the new registry
    docker push "$REGISTRY/$REPOSITORY:$TAG"

done < "$IMAGE_LIST_FILE"
