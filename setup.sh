#!/bin/bash

ffmpeg_path="ffmpeg"
colmap_path="colmap"
python3_path="python3"
brush_path="brush_app"

if [ -z $1 ]; then
    echo "Error: No video path supplied"
    exit 1
fi

file_path=$1

replaced=$(echo "$file_path" | sed "s/\\ / /g")
s="$replaced"
last_slash_index=-1
for ((i=0; i<${#s}; i++)); do
  if [ "${s:$i:1}" = "/" ]; then
    last_slash_index=$i
  fi
done

folder_path=${s:0:last_slash_index+1}

mkdir "${folder_path}colmap"

if [ ! -d "${folder_path}colmap/images" ]; then
    mkdir "${folder_path}colmap/images"
    "$ffmpeg_path" -i "$file_path" "${folder_path}colmap/images/%4d.png"
fi

if [[ "$2" == "--eval-sharpness" ]]; then
    "$python3_path" ./sharpness.py "${folder_path}colmap/images/"
fi

"$colmap_path" automatic_reconstructor --workspace_path "${folder_path}colmap" --image_path "${folder_path}colmap/images" --data_type video --quality high --sparse 1 --dense 0 --use_gpu 1 --gpu_index -1 --num_threads -1

"$brush_path" "${folder_path}colmap/" --total-steps 90000 --max-resolution 8000 --export-every 2000 --export-path "${folder_path}" --with-viewer
