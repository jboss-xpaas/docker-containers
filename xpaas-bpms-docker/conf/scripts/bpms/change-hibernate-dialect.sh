#!/bin/bash

# Program arguments
#
# -war | --war-file:		The path for the WAR file.
#				Mandatory
# -d | --dialect:		The full qualified name for the new dialect class.
#				Mandatory
# -t | --temp-dir:		The temporary directory to use.
#				Optional - Defaults to /tmp
# -h | --help;			Show the script usage
#


function usage
{
    echo "usage: start.sh [[[-war <war_file> ] [-d <dialect_classname>] [-t <temp_path>]] | [-h]]"
}

WAR_PATH=
DIALECT=
TMP_DIR=/tmp
DEFAULT_DIALECT="org.hibernate.dialect.H2Dialect"

while [ "$1" != "" ]; do
    case $1 in
        -war | --war-file ) shift
                                WAR_PATH=$1
                                ;;
        -d | --dialect )  shift
                                DIALECT=$1
                                ;;
        -t | --temp-dir )  shift
                                TMP_DIR=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [[ -z "$WAR_PATH" ]] ; then
	echo "No WAR file path specified."
	exit 65
fi

WAR_NAME=$(basename $WAR_PATH)

if [[ -z "$DIALECT" ]] ; then
	echo "No dialect specified."
	exit 65
fi

if [ ! -f $WAR_PATH ];
then
   echo "File $WAR_PATH does not exist."
   exit 1
fi

PERSISTENCE_XML_PATH=WEB-INF/classes/META-INF/persistence.xml
RESULT_FILE=WEB-INF/classes/META-INF/persistence.xml.new

pushd .
# Create temp directories.
cd $TMP_DIR
mkdir _war
cd _war/

# Override content in persistence.xml
cp -f $WAR_PATH .
jar xf $WAR_NAME

if [ ! -f $PERSISTENCE_XML_PATH ];
then
   echo "JPA Persistence descritpor not found."
   rm -rf $TMP_DIR/_war
   popd
   exit 1
fi

# Replace the original hibernate dialec for the new one.
sed -e "s;$DEFAULT_DIALECT;$DIALECT;" $PERSISTENCE_XML_PATH > $RESULT_FILE
mv -f $RESULT_FILE $PERSISTENCE_XML_PATH

# Update the persitence.xml in WAR file
jar uf $WAR_NAME $PERSISTENCE_XML_PATH

# Override original WAR file with new one
cp -f $WAR_NAME $WAR_PATH

# Remove temp directory
rm -rf $TMP_DIR/_war

popd

exit 0
