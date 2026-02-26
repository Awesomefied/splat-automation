import os
import sys
from os import listdir
from os.path import isfile, join

import cv2
import numpy as np


def image_sharpness(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    laplacian = cv2.Laplacian(gray, cv2.CV_64F)
    return laplacian.var()


if len(sys.argv) < 2:
    sys.exit("Error: No folder provided")

folder = sys.argv[1]
print(folder)
images = [f for f in listdir(folder) if isfile(join(folder, f))]
images.sort()
imgsharpness = {}

for i in range(len(images)):
    image = cv2.imread(folder + images[i])
    sharpness = image_sharpness(image)
    imgsharpness[i] = sharpness
    print(
        "Reading image: " + images[i] + " (" + str(i + 1) + "/" + str(len(images)) + ")"
    )

imgsharpness = dict(
    sorted(imgsharpness.items(), key=lambda item: item[1], reverse=True)
)

# limit is 1/4 the max sharpness value
limit = imgsharpness[list(imgsharpness.keys())[0]] / 4

for i in range(len(list(imgsharpness.keys()))):
    index = list(imgsharpness.keys())[i]
    # if an images sharpness value < limit it gets deleted
    if imgsharpness[index] < limit:
        print("Removing image: " + images[index])
        os.remove(folder + images[index])
