#!/bin/bash
# if the symbolic link is not present in the annovar conda virtual environment the script search for the tar.gz in the conda_prefix,
# untar the archive and make a symbolic link to the $CONDA_PREFIX of the conda virtual environment
if [[ ! -d $CONDA_PREFIX/annovar ]] ; then
	tar -zxvf $CONDA_PREFIX/../../annovar.*.tar.gz -C $CONDA_PREFIX/../../ &&
	echo start untar &&
	ln -s $CONDA_PREFIX/../../annovar $CONDA_PREFIX &&
	echo all done
else
	echo annovar was present
fi
