#!/bin/bash

ARCH=arch.json
TARGET=vitis_ai_library/models
CACHE=../cache/AI-Model-Zoo-v1.4

function build_model() {
	for file in `ls $1`
	do
		if [ -d $1"/"$file ]; 
		then
			build_model $1"/"$file
		elif [ -f $1"/"$file ];
		then
			grep -r "download link:" $1"/"$file > download_list.txt
			sed -i 's/^.................//' download_list.txt

			grep -r "name:" $1"/"$file > name_list.txt
			sed -i 's/^........//' name_list.txt
	
			grep -r "checksum:" $1"/"$file > checksum_list.txt
			sed -i 's/^............//' checksum_list.txt
	
			echo $1 > model_path.txt
			sed -i 's/^.............//' model_path.txt
			framework_prefix=$(cut -c1-3 model_path.txt)
                        #echo "$framework_prefix"

                        # float&quantized model
                        download1=$(sed -n '1p' download_list.txt)
			checksum1=$(sed -n '1p' checksum_list.txt)
			archive1=$(echo $download1 | cut -f2 -d=)
			file1="${CACHE}/$archive1"
			echo "$download1 => $archive1"
                        
                        # pre-built zcu102/zcu04 model
                        download2=$(sed -n '2p' download_list.txt)
			checksum2=$(sed -n '2p' checksum_list.txt)
                        archive2=$(echo $download2 | cut -f2 -d=)
			file2="${CACHE}/$archive2"
			echo "$download2 => $archive2"

			modelpath=$(sed -n '1p' model_path.txt)

                        netname=$(sed -n '2p' name_list.txt)

                        if [[ -d "${TARGET}/$netname" ]]; then
				echo "Skipping $modelpath since ${TARGET}/$netname already exists ..."
			#elif [ "$modelpath" == "pt_pointpainting_nuscenes_1.4" ]; then
			#	echo "Skipping $modelpath since unresolved issues ..."
			#elif [ "$modelpath" == "pt_pointpillars_nuscenes_40000_64_108G_1.4" ]; then
			#	echo "Skipping $modelpath since unresolved issues ..."
			#elif [ "$modelpath" == "pt_sa-gate_NYUv2_360_360_178G_1.4" ]; then
			#	echo "Skipping $modelpath since unresolved issues ..."
			#elif [ "$modelpath" == "tf_rcan_DIV2K_360_640_0.98_86.95G_1.4" ]; then
			#	echo "Skipping $modelpath since unresolved issues ..."
                        else
				if [ "$framework_prefix" != "tor" ]; then
                                        if [[ -f "$file1" ]]; then
						echo "Skipping download of $archive1 since already in cache ..."
					else
						echo "Downloading $archive1 ..."
						wget $download1 -O $file1
					fi
					#check_result=`md5sum -c <<<"$checksum1 $file1"`
					#if [ "$check_result" != "$file1: OK" ]; then
	   				#	echo "md5sum check failed! Please try to download again."
	   				#	exit 1
					#else
						if [ `command -v unzip` ]; then
	      						unzip $file1
	   					else 
	      						sudo apt install unzip
	      						unzip $file1
	   					fi
						#rm $file1
					#fi
                                        if [[ -f "$file2" ]]; then
						echo "Skipping download of $archive2 since already in cache ..."
					else
						echo "Downloading $archive2 ..."
						wget $download2 -O $file2
					fi
					#check_result=`md5sum -c <<<"$checksum2 $file2"`
					#if [ "$check_result" != "$file2: OK" ]; then
	   				#	echo "md5sum check failed! Please try to download again."
	   				#	exit 1
					#else
						tar -xvzf $file2
						#rm $file2
					#fi
				else
					echo "Torchvision has no float&quantized model"
				fi


				source /opt/vitis_ai/conda/etc/profile.d/conda.sh

				if [ "$framework_prefix" == "cf_" ]; then
			                echo "Compiling caffe model $modelpath as $netname"
					conda activate vitis-ai-caffe
					vai_c_caffe --prototxt $modelpath/quantized/deploy.prototxt \
		    				--caffemodel $modelpath/quantized/deploy.caffemodel \
		    				--arch ${ARCH} \
		    				--output_dir ${TARGET}/$netname \
		    				--net_name $netname 
					conda deactivate
				elif [ "$framework_prefix" == "dk_" ]; then
			                echo "Compiling darknet model $modelpath as $netname"
					conda activate vitis-ai-caffe
					vai_c_caffe --prototxt $modelpath/quantized/deploy.prototxt \
		                                --caffemodel $modelpath/quantized/deploy.caffemodel \
		                                --arch ${ARCH} \
		                                --output_dir ${TARGET}/$netname \
		                                --net_name $netname 
					conda deactivate
				elif [ "$framework_prefix" == "tf_" ]; then
			                echo "Compiling tensorflow model $modelpath as $netname"
					conda activate vitis-ai-tensorflow
					if [ "$modelpath" == "tf_yolov3_voc_416_416_65.63G_1.4" ]; then
						vai_c_tensorflow --frozen_pb $modelpath/quantized/*quantize_eval_model.pb \
		         				--arch ${ARCH} \
		         				--output_dir ${TARGET}/$netname \
		         				--net_name $netname \
							--options '{"input_shape": "1,416,416,3"}'
					elif [ "$modelpath" == "tf_ssdinceptionv2_coco_300_300_9.62G_1.4" ]; then
						vai_c_tensorflow --frozen_pb $modelpath/quantized/*quantize_eval_model.pb \
		                                        --arch ${ARCH} \
		                                        --output_dir ${TARGET}/$netname \
		                                        --net_name $netname \
		                                        --options '{"input_shape": "1,300,300,3"}'
					elif [ "$modelpath" == "tf_ssdresnet50v1_fpn_coco_640_640_178.4G_1.4" ]; then
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
				elif [ "$framework_prefix" == "tf2" ]; then
			                echo "Compiling tensorflow 2 model $modelpath as $netname"
					conda activate vitis-ai-tensorflow2
					vai_c_tensorflow2 -m $modelpath/quantized/quantized.h5 \
		          			-a ${ARCH} \
		          			-o ${TARGET}/$netname \
		          			-n $netname 
					conda deactivate
				elif [ "$framework_prefix" == "pt_" ]; then
			                echo "Compiling pytorch model $modelpath as $netname"
					conda activate vitis-ai-pytorch
					if [ "$modelpath" == "pt_salsanextv2_semantic-kitti_64_2048_32G_1.4" ]; then
						modelpath=pt_salsanextv2_semantic-kitti_64_2048_0.75_32G_1.4
					fi
					if [ "$modelpath" == "pt_pointpillars_kitti_12000_100_10.8G_1.4" ]; then
						vai_c_xir -x $modelpath/qat/convert_qat_results/VoxelNet_0_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/pointpillars_kitti_12000_0_pt \
		                                       -n pointpillars_kitti_12000_0_pt
						vai_c_xir -x $modelpath/qat/convert_qat_results/VoxelNet_1_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/pointpillars_kitti_12000_1_pt \
		                                       -n pointpillars_kitti_12000_1_pt
					elif [ "$modelpath" == "pt_centerpoint_astyx_2560_40_54G_1.4" ]; then
						vai_c_xir -x $modelpath/qat/convert_qat_results/CenterPoint_quant_0_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/centerpoint_0_pt \
		                                       -n centerpoint_0_pt
						vai_c_xir -x $modelpath/qat/convert_qat_results/CenterPoint_quant_1_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/centerpoint_1_pt \
		                                       -n centerpoint_1_pt
					elif [ "$modelpath" == "pt_fadnet_sceneflow_576_960_359G_1.4" ]; then
						vai_c_xir -x $modelpath/quantized/FADNet_0_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/FADNet_0_pt \
		                                       -n FADNet_0_pt
						vai_c_xir -x $modelpath/quantized/FADNet_1_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/FADNet_1_pt \
		                                       -n FADNet_1_pt
						vai_c_xir -x $modelpath/quantized/FADNet_2_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/FADNet_2_pt \
		                                       -n FADNet_2_pt
					elif [ "$modelpath" == "pt_pointpainting_nuscenes_1.4" ]; then
						vai_c_xir -x $modelpath/pointpillars/quantized/MVXFasterRCNN_quant_0_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/pointpainting_nuscenes_40000_64_0_pt \
		                                       -n pointpainting_nuscenes_40000_64_0_pt
						vai_c_xir -x $modelpath/pointpillars/quantized/MVXFasterRCNN_quant_1_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/pointpainting_nuscenes_40000_64_1_pt \
		                                       -n pointpainting_nuscenes_40000_64_1_pt
						vai_c_xir -x $modelpath/semanticfpn/quantized/FPN_int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/semanticfpn_nuimage_576_320_pt \
		                                       -n semanticfpn_nuimage_576_320_pt
					else
						vai_c_xir -x $modelpath/quantized/*int.xmodel \
		                                       -a ${ARCH} \
		                                       -o ${TARGET}/$netname \
		                                       -n $netname
					fi
					conda deactivate
				elif [ "$framework_prefix" == "tor" ]; then
			                echo "WARNING : Cannot compile torchvision model $modelpath"
				else
			                echo "ERROR : Cannot compile model $modelpath"
				fi

				rm -rf $modelpath

                                # additional prep for use with vitis-ai-library
				if [[ -d "${TARGET}/$netname" ]]; then
					if [ "$modelpath" == "pt_pointpillars_kitti_12000_100_10.8G_1.4" ]; then
						# create .prototxt files based on pre-built zcu102/zcu104 models
						echo "Creating pointpillars_kitti_12000_0_pt.prototxt file from pre-built zcu102/zcu104 model"
						cp ${netname}/${netname}.prototxt ${TARGET}/pointpillars_kitti_12000_0_pt/pointpillars_kitti_12000_0_pt.prototxt
						cp ${netname}/${netname}_officialcfg.prototxt ${TARGET}/pointpillars_kitti_12000_0_pt/pointpillars_kitti_12000_0_pt_officialcfg.prototxt
						echo "Creating pointpillars_kitti_12000_1_pt.prototxt file from pre-built zcu102/zcu104 model"
						cp ${netname}/${netname}.prototxt ${TARGET}/pointpillars_kitti_12000_1_pt/pointpillars_kitti_12000_1_pt.prototxt
						sed -i 's/pointpillars_kitti_12000_0_pt/pointpillars_kitti_12000_1_pt/' ${TARGET}/pointpillars_kitti_12000_1_pt/pointpillars_kitti_12000_1_pt.prototxt
					else
						# remove unused _org.xmodel files
						if [[ -f "${TARGET}/${netname}/${netname}_org.xmodel" ]]; then
							echo "Removing ${TARGET}/${netname}/${netname}_org.xmodel ..."
							rm ${TARGET}/${netname}/${netname}_org.xmodel
						fi
						# create ${netname}.prototxt file based on pre-built zcu102/zcu104 model
						if [[ -f "${netname}/${netname}.prototxt" ]]; then
							echo "Copying $netname.prototxt file from pre-built zcu102/zcu104 model"
							cp ${netname}/${netname}.prototxt ${TARGET}/${netname}/.
						fi
						# create ${netname}_officialcfg.prototxt file based on pre-built zcu102/zcu104 model
						if [[ -f "${netname}/${netname}_officialcfg.prototxt" ]]; then
							echo "Copying ${netname}_officialcfg file from pre-built zcu102/zcu104 model"
							cp ${netname}/${netname}_officialcfg.prototxt ${TARGET}/${netname}/.
						fi
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
#rm download_list.txt name_list.txt checksum_list.txt model_path.txt
echo "All models are built succesfully."
