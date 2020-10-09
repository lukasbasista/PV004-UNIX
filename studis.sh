#!/bin/bash

#Project path
XPATH=$PWD

#Force switch
FORCE=false

#Separator
SEP="+"

#Files
LOGFILE="studislog"
FACULTY="faculty"
TERM="term"
SUBJECT="subject"
STUDENT="student"
REGISTER="register"
MARK="mark"

#Argument count
N=1

#Error messages
ARGNUM="incorrect number of arguments."
DIR_CREATE="Directory could not be created."
DIR_WRITE="directory is not writable."
ARG_MANY="Too many arguments."
DIR_DELETE="the directory cannot be deleted."
F_MISSING="Missing FORCE operator. User \"-f\"."
FAC_EXIST="The faculty already exists."
FAC_ID_LEN="The maximum length of the faculty ID is 8 characters."
FAC_DELETE="This faculty cannot be deleted."
FAC_EXIST="The faculty does not exist."
DATE_INVALID="Invalid date."
DATE_RANGE="Date is out of range."
TERM_EXIST="The semester does not exist."
TERM_DELETE="This semester cannot be deleted."
TERM_WRITE="Failed to write this semester."
TERM_ALREADY_EXIST="This semester already exists."
SUBJECT_CODE_INVALID="Invalid subject code."
SUBJECT_CODE_ALREADY_EXIST="Subject with this code already exists."
SUBJECT_NOT_EXIST="Subject does not exist."
SUBJECT_NOT_REGISTERED="The subject is not registered."
SUBJECT_OR_UCO_NOT_EXIST="Subject or UČO does not exist."
EVAL_VALUES="Invalid value for evaluation method. Allowed values: zk, z, k."
CREDIT_RANGE="Number of credits outside the allowed range <0-20>."
FILE_NOT_EXIST="File not found."
FILE_EMPTY="The file is empty"
UCO_INVALID="Invalid UČO."
UCO_EXIST="UCO already exist."
UCO_NOT_EXIST="UCO does not exist"
NAME_MISSING="First or last name is empty."
MAIL_FORMAT="Invalid Email"
STUDENT_HAVE_SUBJECT="The student already has this subject registered."
STUDENT_NOT_HAVE_SUBJECT="The student has not registered this subject."
STUDENT_HAVE_MARKS="Student already have 3 marks in this subject."
STUDENT_COMPLETED_SUBJECT="The student has successfully completed this course."
MARK_INVALID="Invalid mark."
OPERAND="Invalid operand"
ARG_INVALID="Invalid argument"

ERROR () {
    echo $1 >&2
    exit $2
}

logit()
{
    DATEANDTIME=$(/bin/date +"%Y-%m-%d %H:%M.%S");
    echo $DATEANDTIME $$ ${LOGNAME:=x} $0 $@ >> ${XPATH}/${LOGFILE};
}


############################
###         Main         ###
############################

printHelp () {
    echo "Study information system";
    echo "";
    echo "OPTIONS:";
    echo "	-d [path]";
    echo "		change working path.";
    echo "	-f";
    echo "		enable force option";
    echo "";
    echo "OPERANDS:";
    echo "	help";
    echo "		show informations.";
    echo "	print-log";
    echo "		prints the contents of the log file";
    echo "	dir-path, directory-path";
    echo "		prints working path";
    echo "	dir-delete | directory-delete";
    echo "		delete working directory with all files";
    echo "	faculty-delete id";
    echo "		operation delete faculty with entered id";
    echo "	faculty-create id name";
	echo "		create new faculty with entered id and name";
	echo "	faculty-print [id]";
	echo "		print all facults or faculty with entered id";
	echo "	faculty-name id name";
	echo "		change name of faculty with entered id";
	echo "	term-delete faculty id";
	echo "		delete term with entered faculty and id";
	echo "	term-date faculty id date (YYYY-MM-DD)";
	echo "		change term date";
	echo "	term-name faculty id name";
	echo "		change term name";
	echo "	term-print [faculty id]";
	echo "		prints all terms or terms of entered faculty";
	echo "	term-create faculty id date name";
	echo "		create new term";
	echo "	subject-print [faculty [term [subject_code]]]";
	echo "		prints subjects";
	echo "	subject-name faculty term subject_code subject_name";
	echo "		change subject name";
	echo "	subject-delete faculty term subject_code";
	echo "		delete subject with entered data";
	echo "	subject-credits faculty term subject_code credits";
	echo "		change credits value for subject";
	echo "	subject-evaluation, subject-eval faculty term subject_code evaluation";
	echo "		change evaluation of subject";
	echo "	subject-create faculty term subject_c♂de subject_name evaluation credits";
	echo "		create new subject";
	echo "	student-export";
	echo "		prints all registered students";
	echo "	student-new UCO first_name last_name birth_date email";
	echo "		add new student to system";
	echo "	student-delete UCO";
	echo "		delete student";
	echo "	register faculty term subject_code UCO";
	echo "		register subject to student";
	echo "	register-subject faculty term subject_code";
	echo "		print students which have registered subject";
	echo "	mark faculty term subject_code UCO mark";
	echo "		add mark from subject to student";
	echo "	unregister faculty term subject_code UCO";
	echo "		unregister subject fr♂m student";
	echo "	mark-print faculty term subject_code | mark-print UCO";
	echo "		prints marks of subject or student";
	echo "";
    exit 0;
}

changeDirectory () {
    case $1 in
        /*) NPATH=$1 ;;
        *) NPATH=${XPATH}/${1} ;;
    esac
    if [ ! -d $NPATH ]; then
        if ! mkdir -p $NPATH;then
            ERROR "$DIR_CREATE" 1;
        fi
    fi
    if ! [ -w $NPATH ]; then
        ERROR "$DIR_WRITE" 2;
    fi
    XPATH=$NPATH
    if ! test -f ${XPATH}/${logfile}; then
        touch ${XPATH}/${logfile}
    fi
}

printDirectory () {
    echo $XPATH
}

printLog () {
    if test $# -le 1;then
        if test $# -eq 0;then
            cat ${XPATH}/${LOGFILE}
        else
            if ! egrep "$1" ${XPATH}/${LOGFILE};then
                exit 1;
            fi
        fi
    else
        ERROR "$ARG_MANY" 4;
    fi
}

deleteDir () {
    if $FORCE; then
        if ! rm -r $XPATH;then
            ERROR "$DIR_DELETE" 5;
        fi
    else
        ERROR "$F_MISSING" 6;
    fi
}


###########################
###       Faculty       ###
###########################

addfaculty () {
    if [ ! -d ${XPATH}/${FACULTY} ]; then
        touch ${XPATH}/${FACULTY}
    fi
    if ! test $# -eq 2;then
        ERROR "$ARGNUM" 7;
    else
        if ! test ${#1} -gt 8;then
            if cut -d$SEP -f1 ${XPATH}/${FACULTY} | grep -q $1;then
                ERROR "$FAC_EXIST" 8;
            fi
            echo ${1}${SEP}${2} >> ${XPATH}/${FACULTY}
        else
            ERROR "$FAC_ID_LEN" 9;
        fi
    fi
}

rmfaculty () {
    if ! test $# -eq 1;then
        ERROR "$ARGNUM" 10;
    fi
    if cut -d$SEP -f1 ${XPATH}/${FACULTY} | grep -q $1;then
        if test -f ${XPATH}/${TERM}; then
            if cut -d$SEP -f1 ${XPATH}/${TERM} | grep -q "${1}";then
                ERROR "$FAC_DELETE" 11;
            fi
        fi
        sed -i "/^$1/d" ${XPATH}/${FACULTY}
    else
        ERROR "$FAC_EXIST" 12;
    fi
}

printfaculty () {
    if test $# -gt 1;then
        ERROR "$ARGNUM" 13;
    fi
    echo "Fakulta  | Název"
    echo "--------------------------"
    cat ${XPATH}/${FACULTY}|(IFS=$SEP; while read ID NAME ZBYTEK;do 
        if test $# -eq 1; then
            if echo $ID | grep -q $1; then
                printf '%-8s | %s\n' $ID $NAME
            fi
        else
            printf '%-8s | %s\n' $ID $NAME
        fi; done) | sort
}

changename () {
    if test $# -eq 2; then
        if cut -d$SEP -f1 ${XPATH}/${FACULTY} | grep -q $1;then
            sed -i "s/${1}${SEP}.*/${1}${SEP}${2}/" ${XPATH}/${FACULTY}
        else
            ERROR "$FAC_EXIST" 14;
        fi
    else
        ERROR "$ARGNUM" 15; 
    fi
}


############################
###         Terms        ###
############################

checkDate () {
    if ! test $# -eq 1; then
        ERROR "$ARGNUM" 16;
    fi
    if ! date "+%Y-%m-%d" -d "$1" > /dev/null || ! [[ $1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]> /dev/null; then
        ERROR "$DATE_INVALID" 17;
    fi
    FIRST_DATE=$(date -d 2000-01-01 +%s)
    MY_DATE=$(date -d $1 +%s)
    LAST_DATE=$(date -d "$DATE + 2 year" +%s)
    if ! (test $MY_DATE -ge $FIRST_DATE && test $MY_DATE -le $LAST_DATE);then
        ERROR "$DATE_RANGE" 18;
    fi
    return 0
}

checkStudentDate () {
    if ! test $# -eq 1; then
        ERROR "$ARGNUM" 19;
    fi
    if ! date "+%Y-%m-%d" -d "$1" > /dev/null || ! [[ $1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]> /dev/null; then
        ERROR "$DATE_INVALID" 20;
    fi
    FIRST_DATE=$(date -d 1900-01-01 +%s)
    MY_DATE=$(date -d $1 +%s)
    LAST_DATE=$(date -d "$DATE" +%s)
    if ! (test $MY_DATE -ge $FIRST_DATE && test $MY_DATE -le $LAST_DATE);then
        ERROR "$DATE_RANGE" 21;
    fi
    return 0
}

termExist () {
    if cut -d$SEP -f1,2 ${XPATH}/${TERM} | grep -q "${1}${SEP}${2}";then
        return 0
    fi
    return 1
}

termDelete () {
    if ! test $# -eq 2;then
        ERROR "$ARGNUM" 22;
    fi
    if ! termExist $1 $2;then
        ERROR "$TERM_EXIST" 23;
    fi
    if test -f ${XPATH}/${SUBJECT}; then
        if cut -d$SEP -f1,2 ${XPATH}/${TERM} | grep -q "${1}${SEP}${2}";then
            ERROR "$TERM_DELETE" 24;
        fi
    fi
    sed -i "/^${1}${SEP}${2}/d" ${XPATH}/${TERM}
}

termDate () {
    if ! test $# -eq 3;then
        ERROR "$ARGNUM" 25;
    fi
    checkDate "$3";
    if ! termExist $1 $2; then
        ERROR "$TERM_EXIST" 26;
    fi
    sed -i "s/${1}${SEP}${2}${SEP}.*${SEP}/${1}${SEP}${2}${SEP}${3}${SEP}/g" ${XPATH}/${TERM};
}

termName () {
    if ! termExist "$1" "$2";then
        ERROR "$TERM_EXIST" 27;
    fi
    sed -i "s/\($1\)$SEP\($2\)$SEP\(.*\)$SEP\(.*\)/\1$SEP\2$SEP\3${SEP}${3}/" ${XPATH}/${TERM};
}

termPrint () {
    if test $# -gt 2;then
        ERROR "$ARGNUM" 28;
    fi
    if test $# -eq 2 && ! termExist $1 $2;then
        ERROR "$TERM_WRITE" 29;
    fi
    if test $# -eq 1 && ! cut -d$SEP -f1 ${XPATH}/${TERM} | grep -q "${1}";then
        ERROR "$TERM_WRITE" 30;
    fi
    printf "%-8s | %-8s | %-10s | %s\n" "Fakulta" "Semestr" "Od" "Název"
    echo "-----------------------------------------"
    cat ${XPATH}/${TERM}|(IFS=$SEP; while read FAC ID XDATE NAME ZBYTEK;do 
        if test $# -eq 2; then
            if echo "${FAC}${SEP}${ID}" | grep -q "${1}$SEP${2}"; then
                printf "%-8s | %-8s | %-10s | %s\n" $FAC $ID $XDATE $NAME
            fi
        elif test $# -eq 1; then
            if echo "$FAC" | grep -q "$1"; then
                printf "%-8s | %-8s | %-10s | %s\n" $FAC $ID $XDATE $NAME
            fi
        else
            printf "%-8s | %-8s | %-10s | %s\n" $FAC $ID $XDATE $NAME
        fi; done) | sort -t '|' -k 3 -k 1
}

termCreate () {
    if [ ! -f ${XPATH}/${TERM} ]; then
        touch ${XPATH}/${TERM}
    fi
    if ! cut -d$SEP -f1 ${XPATH}/${FACULTY} | grep -q $1;then
        ERROR "$FAC_EXIST" 31;
    fi
    if test ${#2} -gt 8;then
        ERROR "$FAC_ID_LEN" 32;
    fi
    checkDate "$3"
    if termExist $1 $2; then
        ERROR "$TERM_ALREADY_EXIST" 33;
    fi
    echo ${1}${SEP}${2}${SEP}${3}${SEP}${4} >> ${XPATH}/${TERM}
}


############################
###       Subjects       ###
############################

subjectNew () {
    if [ ! -f ${XPATH}/${SUBJECT} ]; then
        touch ${XPATH}/${SUBJECT}
    fi
    if ! cut -d$SEP -f1 ${XPATH}/${FACULTY} | grep -q $1;then
        ERROR "$FAC_EXIST" 34;
    fi
    if ! cut -d$SEP -f1,2 ${XPATH}/${TERM} | grep -q "${1}${SEP}${2}$";then
        ERROR "$TERM_EXIST" 35;
    fi
    if ! [[ $3 =~ ^[A-Za-z][a-zA-Z0-9_]{0,7}$ ]];then
        ERROR "$SUBJECT_CODE_INVALID" 36;
    fi
    if cut -d$SEP -f3 ${XPATH}/${SUBJECT} | grep -i -q $3;then
        ERROR "$SUBJECT_CODE_ALREADY_EXIST" 37;
    fi
    if [ "$5" != "zk" ] && [ "$5" != "k" ] && [ "$5" != "z" ];then
        ERROR "$EVAL_VALUES" 38;
    fi
    if ! (test $6 -ge 0 && test $6 -le 20);then
        ERROR "$CREDIT_RANGE" 39;
    fi
    echo ${1}${SEP}${2}${SEP}${3}${SEP}${4}${SEP}${5}${SEP}${6} >> ${XPATH}/${SUBJECT}
}

subjectExist () {
    if test $# -eq 3 && cut -d$SEP -f1,2,3 ${XPATH}/${SUBJECT} | grep -i -q "${1}${SEP}${2}${SEP}${3}";then
        return 0
    fi
    if test $# -eq 2 && cut -d$SEP -f1,2 ${XPATH}/${SUBJECT} | grep -q "${1}${SEP}${2}";then
        return 0
    fi
    if test $# -eq 1 && cut -d$SEP -f1 ${XPATH}/${SUBJECT} | grep -q "${1}";then
        return 0
    fi
    return 1
}

subjectName () {
    if ! subjectExist "$1" "$2" "$3";then
        ERROR "$SUBJECT_NOT_EXIST" 40;
    fi
    sed -i "s/\($1\)$SEP\($2\)$SEP\($3\)$SEP\(.*\)$SEP\(.*\)$SEP\(.*\)/\1$SEP\2$SEP\3${SEP}${4}${SEP}\5${SEP}\6/i" ${XPATH}/${SUBJECT};
}

subjectCredits () {
    if ! test $# -eq 4;then
        ERROR "$ARGNUM" 41;
    fi
    if ! subjectExist "$1" "$2" "$3";then
        ERROR "$SUBJECT_NOT_EXIST" 41;
    fi
    if ! (test $4 -ge 0 && test $4 -le 20);then
        ERROR "$CREDIT_RANGE" 42;
    fi
    sed -i "s/\($1\)$SEP\($2\)$SEP\($3\)$SEP\(.*\)$SEP\(.*\)$SEP\(.*\)/\1${SEP}\2${SEP}\3${SEP}\4${SEP}\5${SEP}${4}/i" ${XPATH}/${SUBJECT};
}

subjectFinal () {
    if ! test $# -eq 4;then
        ERROR "$ARGNUM" 43;
    fi
    if ! subjectExist "$1" "$2" "$3";then
        ERROR "$SUBJECT_NOT_EXIST" 44;
    fi
    if [ "$4" != "zk" ] && [ "$4" != "k" ] && [ "$4" != "z" ];then
        ERROR "$EVAL_VALUES" 45;
    fi
    sed -i "s/\($1\)$SEP\($2\)$SEP\($3\)$SEP\(.*\)$SEP\(.*\)$SEP\(.*\)/\1${SEP}\2${SEP}\3${SEP}\4${SEP}${4}${SEP}\6/i" ${XPATH}/${SUBJECT};
}

subjectDelete () {
    if ! test $# -eq 3;then
        ERROR "$ARGNUM" 46;
    fi
    if ! subjectExist "$1" "$2" "$3";then
        ERROR "$SUBJECT_NOT_EXIST" 47;
    fi
    if isRegistered "$1" "$2" "$3";then
        ERROR "$SUBJECT_NOT_EXIST" 48;
    fi
    sed -i "/^${1}${SEP}${2}${SEP}${3}/Id" ${XPATH}/${SUBJECT}
}

subjectPrint () {
    if ! test -f ${XPATH}/${SUBJECT}; then
        ERROR "$FILE_NOT_EXIST" 49;
    fi
    if test $# -gt 3;then
        ERROR "$ARGNUM" 50;
    fi
    if test $# -gt 0 && ! subjectExist $*;then
        ERROR "$SUBJECT_NOT_EXIST" 51;
    fi
    printf "%-8s | %-8s | %-8s | %-2s | %-2s | %s\n" "Fakulta" "Semestr" "Kurz" "Uk" "Kr" "Název"
    echo "----------------------------------------------------"
    cat ${XPATH}/${SUBJECT}|(IFS=$SEP; while read FAC ID KUR NAME UK KR ZBYTEK;do 
        if test $# -eq 3; then
            if echo "${FAC}${SEP}${ID}${SEP}${KUR}" | grep -i -q "${1}$SEP${2}$SEP${3}"; then
                printf "%-8s | %-8s | %-8s | %-2s | %2s | %s\n" $FAC $ID $KUR $UK $KR $NAME
            fi
        elif test $# -eq 2; then
            if echo "${FAC}${SEP}${ID}" | grep -q "${1}$SEP${2}"; then
                printf "%-8s | %-8s | %-8s | %-2s | %2s | %s\n" $FAC $ID $KUR $UK $KR $NAME
            fi
        elif test $# -eq 1; then
            if echo "${FAC}" | grep -q "${1}"; then
                printf "%-8s | %-8s | %-8s | %-2s | %2s | %s\n" $FAC $ID $KUR $UK $KR $NAME
            fi
        else
            printf "%-8s | %-8s | %-8s | %-2s | %2s | %s\n" $FAC $ID $KUR $UK $KR $NAME
        fi; done) | sort -t '|' -k 1 -k 2 -k 3
}


############################
###       Students       ###
############################

studentExist () {
    if [ ! -f ${XPATH}/${STUDENT} ]; then
        return 1
    fi
    if cut -d\; -f1 ${XPATH}/${STUDENT} | grep -q $1;then
        return 0
    fi
    return 1
}

studentNew () {
    if [ ! -f ${XPATH}/${STUDENT} ]; then
        touch ${XPATH}/${STUDENT}
    fi
    ucoRE='^[0-9]+$'
    if ! [[ $1 =~ $ucoRE && $1 != "0" ]] ; then
        ERROR "$UCO_INVALID" 52;
    fi
    if studentExist $1 ;then
        ERROR "$UCO_EXIST" 53;
    fi
    if test -z "$2" || test -z "$3";then
        ERROR "$NAME_MISSING" 54;
    fi
    checkStudentDate $4

    emailRE="^[a-z0-9_-]+(\.[a-z0-9_-]+)*@([a-z0-9]([a-z0-9_-]*[a-z0-9_-])?\.)+[a-z0-9_-]([a-z0-9_-]*[a-z0-9_-])?\$"
    if ! [[ $5 =~ $emailRE ]] ; then
        ERROR "$MAIL_FORMAT" 55;
    fi
    echo ${1}\;${2}\;${3}\;${4}\;${5} >> ${XPATH}/${STUDENT}

}

studentDelete () {
    if ! test $# -eq 1;then
        ERROR "$ARGNUM" 56;
    fi
    if ! studentExist $1;then
        ERROR "$UCO_NOT_EXIST" 57;
    fi
    if test -f ${XPATH}/${REGISTER} && cut -d${SEP} -f4 ${XPATH}/${REGISTER} | grep -q $1;then
        ERROR "$STUDENT_HAVE_SUBJECT" 58;
    fi
    sed -i "/^${1}/Id" ${XPATH}/${STUDENT}
}

studentExport () {
    if ! test $# -eq 0;then
        ERROR "$ARGNUM" 59;
    fi
    cat ${XPATH}/${STUDENT}|(IFS=\;; while read UCO MENO PRIEZVISKO DATUM EMAIL ZBYTEK;do 
        printf "%s;%s\n" $UCO $EMAIL;
    done) | sort -n -t ';' -k 1
    if ! [ -s ${XPATH}/${STUDENT} ];then
        ERROR "$FILE_EMPTY" 60;
    fi
}


###########################
###       Register      ###
###########################

isRegistered () {
    if ! test $# -eq 4 && ! test $# -eq 3; then
        ERROR "$ARGNUM" 61;
    fi
    if [ ! -f ${XPATH}/${REGISTER} ]; then
        return 1
    fi
    if test $# -eq 4 && cut -d${SEP} -f1,2,3,4 ${XPATH}/${REGISTER} | grep -i -q ${1}${SEP}${2}${SEP}${3}${SEP}${4};then
        return 0
    fi
    if test $# -eq 3 && cut -d${SEP} -f1,2,3 ${XPATH}/${REGISTER} | grep -i -q ${1}${SEP}${2}${SEP}${3};then
        return 0
    fi
    return 1
}

register () {
    if ! test $# -eq 4;then
        ERROR "$ARGNUM" 62;
    fi
    if ! subjectExist $1 $2 $3;then
        ERROR "$SUBJECT_NOT_EXIST" 63;
    fi
    if ! studentExist $4; then
        ERROR "$SUBJECT_NOT_EXIST" 64;
    fi
    if isRegistered $1 $2 $3 $4 ;then
        ERROR "$STUDENT_HAVE_SUBJECT" 65;
    fi
    echo ${1}${SEP}${2}${SEP}${3}${SEP}${4} >> ${XPATH}/${REGISTER}
}

registerSubject () {
    if ! test $# -eq 3;then
        ERROR "$ARGNUM" 66;
    fi
    if ! isRegistered $1 $2 $3; then
        ERROR "$SUBJECT_NOT_REGISTERED" 67;
    fi
    cat ${XPATH}/${REGISTER}|(IFS=${SEP}; while read FAC TERM CODE UCO ZBYTEK;do
        if echo "${FAC}${SEP}${TERM}${SEP}${CODE}" | grep -i -q "${1}$SEP${2}$SEP${3}"; then
            cat ${XPATH}/${STUDENT}|(IFS=\;; while read UCO2 MENO PRIEZVISKO DATUM EMAIL ZBYTEK;do
                if [[ "$UCO" == "$UCO2" ]]; then 
                    printf "%s, %s; učo %s\n" $PRIEZVISKO $MENO $UCO;
                fi
            done)
        fi
    done) | sort -t ' ' -k 1,1 -k 2,2 -k 4n,4n
    if ! [ -s ${XPATH}/${STUDENT} ];then
        ERROR "$FILE_EMPTY" 68;
    fi
}


###########################
###        Marks        ###
###########################

mark () {
    if ! test $# -eq 5; then
        ERROR "$ARGNUM" 69;
    fi
    if [ ! -f ${XPATH}/${MARK} ]; then
        touch ${XPATH}/${MARK}
    fi
    if ! isRegistered $1 $2 $3 $4 ;then
        ERROR "$STUDENT_NOT_HAVE_SUBJECT" 70;
    fi
    makrsCount="$(grep -r "${1}$SEP${2}$SEP${3}$SEP${4}" ${XPATH}/${MARK} | wc -l)"
    successMark="$(grep -r "${1}$SEP${2}$SEP${3}$SEP${4}$SEP[A-EPZ]" ${XPATH}/${MARK} | wc -l)"
    if test $makrsCount -ge 3; then
        ERROR "$STUDENT_HAVE_MARKS" 71;
    fi
    if test $successMark -ge 1 ; then
        ERROR "$STUDENT_COMPLETED_SUBJECT" 72;
    fi
    cat ${XPATH}/${SUBJECT}|(IFS=$SEP; while read FAC ID KUR NAME UK KR ZBYTEK;do
        if echo "${FAC}${SEP}${ID}${SEP}${KUR}" | grep -i -q "${1}$SEP${2}$SEP${3}"; then
            if ( [[ $UK == "zk" ]] && [[ $5 =~ ^[A-F]$ ]] ) || ([[ $UK == "k" ]] && [[ $5 =~ ^[PN]$ ]]) || ([[ $UK == "z" ]] && [[ $5 =~ ^[ZN]$ ]]) ; then
                DATEANDTIME=$(/bin/date +"%Y-%m-%d %H:%M.%S")
                printf "%s${SEP}%s${SEP}%s${SEP}%s${SEP}%s${SEP}%s\n" $1 $2 $3 $4 $5 $DATEANDTIME;
                exit 
            else
                exit 1;
            fi
        fi
    done) >> ${XPATH}/${MARK}
    if test $? -eq 1;then
        ERROR "$MARK_INVALID" 75;
    fi
}

registerDelete () {
    if ! test $# -eq 4;then
        ERROR "$ARGNUM" 74;
    fi
    if ! isRegistered $1 $2 $3 $4;then
        ERROR "$SUBJECT_NOT_REGISTERED" 75;
    fi
    sed -i "/^${1}${SEP}${2}${SEP}${3}${SEP}${4}/Id" ${XPATH}/${REGISTER}
    sed -i "/^${1}${SEP}${2}${SEP}${3}${SEP}${4}/Id" ${XPATH}/${MARK}
}

markPrint () {
    if ! test $# -eq 1 && ! test $# -eq 3;then
        ERROR "$ARGNUM" 76;
    fi
    if test $# -eq 3 && subjectExist $1 $2 $3;then
        cat ${XPATH}/${MARK}|(IFS=${SEP}; while read FAC TERM CODE UCO MARK DAT ZBYTEK;do
            if echo "${FAC}${SEP}${TERM}${SEP}${CODE}" | grep -i -q "${1}$SEP${2}$SEP${3}"; then
                cat ${XPATH}/${STUDENT}|(IFS=\;; while read UCO2 MENO PRIEZVISKO DATUM EMAIL ZBYTEK;do
                    if [[ "$UCO" == "$UCO2" ]]; then 
                        printf "%s, %s; učo %s: %s %s\n" $PRIEZVISKO $MENO $UCO $MARK $DAT;
                    fi
                done)
            fi
        done) | sort -k 1,1 -k 2,2 -k6,6 -k7,7
    elif test $# -eq 1 && studentExist $1;then
        cat ${XPATH}/${MARK}|(IFS=${SEP}; while read FAC TERM CODE UCO MARK DAT ZBYTEK;do
            if  [[ "$UCO" == "$1" ]]; then
                cat ${XPATH}/${SUBJECT}|(IFS=${SEP}; while read FAC1 ID KUR NAME UK KR ZBYTEK1;do
                    if [[ "${CODE,,}" == "${KUR,,}" ]]; then 
                        printf "%s$SEP%s:$SEP%s$SEP%s\n" $KUR $NAME $MARK $DAT;
                    fi
                done)
            fi
        done) | sort -t '+' -k1,1 -k4,4 | tr '+' ' '
    else
        ERROR "$SUBJECT_OR_UCO_NOT_EXIST" 77;
    fi
}

if ! test -f ${XPATH}/${logfile}; then
    touch ${XPATH}/${logfile}
fi


if test $# -eq 0;then
    ERROR "$ARGNUM" 78;
fi

while getopts 'd:f' VOLBA; do
case "$VOLBA" in
d)	changeDirectory $OPTARG
    N=$((N+2));;
f)	N=$((N+1))
    FORCE=true;;
?)	ERROR "$OPERAND" 79;;
esac
done

logit $@

if test $# -ge $N; then
    ARG=${!N}
    X=$((N+1))
    case "$ARG" in
    help)
        printHelp;;
    print-log)
        printLog ${*:X};;
    dir-path | directory-path)
        if test $# -gt $N; then
            ERROR "$ARGNUM" 80;
        fi
        printDirectory;;
    dir-delete | directory-delete)
        deleteDir;;
    faculty-delete)
        rmfaculty ${*:X};;
    faculty-create)
        if test $# -eq $((N+2));then
            A=$((N+1));B=$((N+2));
            addfaculty ${!A} "${!B}"
        else
            ERROR "$ARGNUM" 81;
        fi;;
    faculty-print)
        printfaculty ${*:X};;
    faculty-name)
        if test $# -eq $((N+2));then
            A=$((N+1));B=$((N+2));
            changename ${!A} "${!B}"
        else
            ERROR "$ARGNUM" 82;
        fi;;
    term-delete)
        termDelete ${*:X};;
    term-date)
        termDate ${*:X};;
    term-name)
        if test $# -eq $((N+3));then
            A=$((N+1));B=$((N+2));C=$((N+3));
            termName ${!A} ${!B} "${!C}"
        else
            ERROR "$ARGNUM" 83;
        fi;;
    term-print)
        termPrint ${*:X};;
    term-create)
        if test $# -eq $((N+4));then
            A=$((N+1));B=$((N+2));C=$((N+3));D=$((N+4));
            termCreate ${!A} ${!B} ${!C} "${!D}"
        else
            ERROR "$ARGNUM" 84;
        fi;;
    subject-print)
        subjectPrint ${*:X};;
    subject-name)
        if test $# -eq $((N+4));then
            A=$((N+1));B=$((N+2));C=$((N+3));D=$((N+4));
            subjectName "${!A}" "${!B}" "${!C}" "${!D}"
        else
            ERROR "$ARGNUM" 85;
        fi;;
    subject-delete)
        subjectDelete ${*:X};;
    subject-credits)
        subjectCredits ${*:X};;
    subject-evaluation | subject-eval)
        subjectFinal ${*:X};;
    subject-create)
        if test $# -eq $((N+6));then
            A=$((N+1));B=$((N+2));C=$((N+3));D=$((N+4));E=$((N+5));F=$((N+6));
            subjectNew "${!A}" "${!B}" "${!C}" "${!D}" "${!E}" "${!F}";
        else
            ERROR "$ARGNUM" 86;
        fi;;
    student-export)
        studentExport ${*:X};;
    student-new)
        if test $# -eq $((N+5));then
            A=$((N+1));B=$((N+2));C=$((N+3));D=$((N+4));E=$((N+5));
            studentNew "${!A}" "${!B}" "${!C}" "${!D}" "${!E}";
        else
            ERROR "$ARGNUM" 87;
        fi;;
    student-delete)
        studentDelete ${*:X};;
    register)
        register ${*:X};;
    register-subject)
        registerSubject ${*:X};;
    mark)
        mark ${*:X};;
    unregister)
        registerDelete ${*:X};;
    mark-print)
        markPrint ${*:X};;
    *)
        ERROR "$ARG_INVALID" 88;;
    esac
else
    ERROR "$ARGNUM" 89;
fi

exit 0