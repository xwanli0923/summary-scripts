#!/bin/bash

# Copyright (C) 2017 hfhua@biotecan.com
# Created: 2017.8.9 15:00, HLF.
# Configure File: PositiveLoci.cfg
# Storage Path: /public/home/liurui/hualf
# Usage: This shell script is used to collect positive locis from configure file.
# Depandence: MergeNameProject.V1.pl, CollectPositiveLoci.ThrDim.V1.pl

# Please pay attention to project 'S124'(kidney_cancer), you must copy TargetGeneDrugV2 manually!

# set -x > set.out.log
# set -e

MasterDir=/public/home/liurui/hualf
BasePath=/public/data/clinical

# :<<BLOCK
cd $MasterDir
if [ -d $MasterDir/LocisTmp ]
then
	rm -r LocisTmp
fi

mkdir $MasterDir/LocisTmp
echo "*** Current working directory is: $(pwd) ***"
echo "*** Right working directory is:   $MasterDir ***"

if [ $(pwd)==$MasterDir ]
then
	read -p "Please input the cfg file: " loci
	read -p "Please type the sample name to know loci. If you don't want, please <Enter>: " sample
else
	echo -e "\n****** Not in the working directory: $MasterDir ******\n"
	exit 1
fi
	# PositiveLoci.cfg: first column is sample name, second column is project.

awk '{ print $1 }' $loci > SampleList.txt
perl MergeNameProject.pl $loci
	# This Perl script ignores '/' project(not found), which have been deleted or be special sample.	

for name in $(cat MergeNameProject.txt)
do
	cd $BasePath/$name/ANNOTATION/ANNOVAR
	
	if [ $? -eq 0 ]
	then
		if [ -f *TargetGeneDrugV2*Drug* ]		
		then
			# B1234 
			TargetDrug=`ls *TargetGeneDrugV2*Drug*`
			echo $TargetDrug
			cp $BasePath/$name/ANNOTATION/ANNOVAR/$TargetDrug $MasterDir/LocisTmp
			continue

		elif [ -f *TargetGeneDrugV2*Y1234* ]
		then
			# Y1234 MMR (tissue->somatic mutation, no blood->genetic mutation)
			TargetDrug=`ls *TargetGeneDrugV2*Y1234*`
			echo $TargetDrug
			cp $BasePath/$name/ANNOTATION/ANNOVAR/$TargetDrug $MasterDir/LocisTmp
			continue

		elif [ -f *TargetGeneDrugV2*BRCA1_2* ]
		then 
			# Olaparib: BRAC1/2 gene
			TargetDrug=`ls *TargetGeneDrugV2*BRCA1_2*`
			echo $TargetDrug
			cp $BasePath/$name/ANNOTATION/ANNOVAR/$TargetDrug $MasterDir/LocisTmp
			continue

		elif [ -f *TargetGeneDrugV2*MMR* ]
		then
			# MMR (only somatic mutation)
			TargetDrug=`ls *TargetGeneDrugV2*MMR*`
			echo $TargetDrug
			cp $BasePath/$name/ANNOTATION/ANNOVAR/$TargetDrug $MasterDir/LocisTmp
			continue
		fi
	
		if [ -f *TargetGeneDrugV2.txt ]
		then
			# not to select gene list, e.g 521 probe, 73 probe(101 gene), etc.
			TargetDrug=`ls *TargetGeneDrugV2.txt`
			echo $TargetDrug
			cp $BasePath/$name/ANNOTATION/ANNOVAR/$TargetDrug $MasterDir/LocisTmp
		fi
	fi
done
	# Copy *TargetGeneDrugV2* file of every sample to target tmp directory.
# BLOCK

wait
echo -e "\n========== *TargetGeneDrugV2* file copyed completely. ==========\n"

# :<<BLOCK
echo "Now collecting positive loci using perl ..."
cd $MasterDir/LocisTmp
chmod 644 *
perl $MasterDir/CollectPositiveLoci.ThrDim.V1.pl . $MasterDir/SampleList.txt $sample
	# Be carefully: using redirect '2> <error>.log' in Perl !

Total=`wc -l $MasterDir/SampleList.txt`
Capture=`wc -l $MasterDir/MergeNameProject.txt`
echo -e "\n ***     Total samples: $Total"
echo -e " *** Collected samples: $Capture"
echo -e "\n========== Collect positive locis completely. ==========\n"

if [ -f *loci.txt ]
then
	echo "$sample positive loci is/are: "
	cat $MasterDir/LocisTmp/${sample}.loci.txt
else
	echo "You haven't select single sample to collect ... PASS ..."
fi

mv PositiveLoci.txt TargetGeneDrugV2.nested.hash.txt $MasterDir
rm -rf $MasterDir/{IgnoredSample.txt,MergeNameProject.txt,SampleList.txt}

echo -e "\n========== \033[44;37;5m All right. \033[0m  ==========\n"
# BLOCK



