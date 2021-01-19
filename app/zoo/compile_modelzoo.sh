#!/bin/bash

ARCH=arch.json
TARGET=vitis_ai_library/models

function build_model() {
	for file in `ls $1`
	do
		if [ -d $1"/"$file ]; 
		then
			build_model $1"/"$file
		elif [ -f $1"/"$file ];
		then
			grep -r "download link:" $1"/"$file > tmp
			sed -i 's/^.................//' tmp

			grep -r "name:" $1"/"$file > tmp0
			sed -i 's/^........//' tmp0
	
			grep -r "checksum:" $1"/"$file > tmp1
			sed -i 's/^............//' tmp1
	
			echo $1 > tmp2
			sed -i 's/^.............//' tmp2
			outputinfostr=$(cut -c1-3 tmp2)
                        #echo "$outputinfostr"

                        # float&quantized model
                        archive1=$(sed -n '1p' tmp)
			checksum1=$(sed -n '1p' tmp1)
                        
                        # pre-built zcu102/zcu04 model
                        archive2=$(sed -n '2p' tmp)
			checksum2=$(sed -n '2p' tmp1)

			modelpath=$(sed -n '1p' tmp2)

                        netname=$(sed -n '2p' tmp0)

                        if [[ -d "${TARGET}/$netname" ]]; then
				echo "Skipping $modelpath since ${TARGET}/$netname already exists ..."
                        else
				if [ "$outputinfostr" != "tor" ]; then
					wget $archive1 -O tmp1.zip
					check_result=`md5sum -c <<<"$checksum1 tmp1.zip"`
					if [ "$check_result" != "tmp1.zip: OK" ]; then
	   					echo "md5sum check failed! Please try to download again."
	   					exit 1
					else
						if [ `command -v unzip` ]; then
	      						unzip tmp1.zip
	   					else 
	      						sudo apt install unzip
	      						unzip tmp1.zip
	   					fi
						rm tmp1.zip
					fi
					wget $archive2 -O tmp2.tar.gz
					check_result=`md5sum -c <<<"$checksum2 tmp2.tar.gz"`
					if [ "$check_result" != "tmp2.tar.gz: OK" ]; then
	   					echo "md5sum check failed! Please try to download again."
	   					exit 1
					else
						tar -xvzf tmp2.tar.gz
						rm tmp2.tar.gz
					fi
				else
					echo "Torchvision has no float&quantized model"
				fi


				source /opt/vitis_ai/conda/etc/profile.d/conda.sh

				if [ "$outputinfostr" == "cf_" ]; then
			                echo "Compiling caffe model $modelpath as $netname"
					conda activate vitis-ai-caffe
					vai_c_caffe --prototxt $modelpath/quantized/deploy.prototxt \
		    				--caffemodel $modelpath/quantized/deploy.caffemodel \
		    				--arch ${ARCH} \
		    				--output_dir ${TARGET}/$netname \
		    				--net_name $netname 
					conda deactivate
				elif [ "$outputinfostr" == "dk_" ]; then
			                echo "Compiling darknet model $modelpath as $netname"
					conda activate vitis-ai-caffe
					vai_c_caffe --prototxt $modelpath/quantized/deploy.prototxt \
		                                --caffemodel $modelpath/quantized/deploy.caffemodel \
		                                --arch ${ARCH} \
		                                --output_dir ${TARGET}/$netname \
		                                --net_name $netname 
					conda deactivate
				elif [ "$outputinfostr" == "tf_" ]; then
			                echo "Compiling tensorflow model $modelpath as $netname"
					conda activate vitis-ai-tensorflow
					if [ "$modelpath" == "tf_yolov3_voc_416_416_65.63G_1.3" ]; then
						vai_c_tensorflow --frozen_pb $modelpath/quantized/*quantize_eval_model.pb \
		         				--arch ${ARCH} \
		         				--output_dir ${TARGET}/$netname \
		         				--net_name $netname \
							--options '{"input_shape": "1,416,416,3"}'
					elif [ "$modelpath" == "tf_ssdinceptionv2_coco_300_300_9.62G_1.3" ]; then
						vai_c_tensorflow --frozen_pb $modelpath/quantized/*quantize_eval_model.pb \
		                                        --arch ${ARCH} \
		                                        --output_dir ${TARGET}/$netname \
		                                        --net_name $netname \
		                                        --options '{"input_shape": "1,300,300,3"}'
					elif [ "$modelpath" == "tf_ssdresnet50v1_fpn_coco_640_640_178.4G_1.3" ]; then
						vai_c_tensorflow --frozen_pb $modelpath/quantized/*quantize_eval_model.pb \
		                                        --arch ${ARCH} \
		                                        --output_dir ${TARGET}/$netname \
		                                        --net_name $netname \
		                                        --options '{"input_shape": "1,640,640,3"}'
					else
						vai_c_tensorflow --frozen_pb $modelpath/quantized/*quantize_eval_model.pb \
		                                        --arch ${ARCH} \
		                                        --output_dir ${TARGET}/$netname \
		                                        --net_name $netname 
					fi
					conda deactivate
				elif [ "$outputinfostr" == "tf2" ]; then
			                echo "Compiling tensorflow 2 model $modelpath as $netname"
					conda activate vitis-ai-tensorflow2
					vai_c_tensorflow2 -m $modelpath/quantized/quantized.h5 \
		          			-a ${ARCH} \
		          			-o ${TARGET}/$netname \
		          			-n $netname 
					conda deactivate
				elif [ "$outputinfostr" == "pt_" ]; then
			                echo "Compiling pytorch model $modelpath as $netname"
					conda activate vitis-ai-pytorch
					if [ "$modelpath" == "pt_pointpillars_kitti_12000_100_10.8G_1.3" ]; then
						vai_c_xir -x $modelpath/quantized/VoxelNet_0_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/$netname \
		                                       -n $netname"_0"
						vai_c_xir -x $modelpath/quantized/VoxelNet_1_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/$netname \
		                                       -n $netname"_1"
					else
						vai_c_xir -x $modelpath/quantized/*int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/$netname \
		                                       -n $netname
					fi
					#ls -p | grep ".xmodel" |
					#while IFS= read -r line
					#do 
					#	vai_c_xir -x $modelpath/quantized/$line \
					#	  	-a ${ARCH} \
					#          	-o ${TARGET}/$netname \
		  			#	  	-n $netname 
					#done
					conda deactivate
				elif [ "$outputinfostr" == "tor" ]; then
			                echo "WARNING : Cannot compile torchvision model $modelpath"
				else
			                echo "ERROR : Cannot compile model $modelpath"
				fi

				rm -rf $modelpath

		                if [[ -d "${TARGET}/$netname" ]]; then
		                    if [[ -f "$netname/$netname.prototxt" ]]; then
		                        echo "Copying $netname.prototxt file from pre-built zcu102/zcu104 model"
		                        cp $netname/$netname.prototxt ${TARGET}/$netname/.
		                    fi
		                fi
		                rm -rf $netname
			fi
		else
			echo $1"/"$file
		fi
	done
}

mkdir -p ${TARGET}
path='./model-list'
build_model $path
rm tmp tmp0 tmp1 tmp2
echo "All models are built succesfully."
