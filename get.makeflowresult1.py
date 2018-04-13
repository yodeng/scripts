#!/usr/bin/env python
#coding:utf-8

import subprocess,argparse,os,sys,re

def argsParse():
    parser = argparse.ArgumentParser(description="This Script is used to get all results of mRNA-Ref project, *report.docx file will be generated under the results directory. if the species is protokaryon, the report.docx will be wrong, please modify manually.")
    parser.add_argument("-od","--od",type=str,help="project directory",required = True)
    parser.add_argument("-config","--configfile",type=str,help="The configfile",required = True)
    parser.add_argument("-name","--name",type=str,help="The makeflow file name",required = True)
    parser.add_argument("-p","--project_num",type=str,help="project number, like '17-0931'",required = True)
    parser.add_argument("-j","--max_jobs",type=int,help="Max number of jobs to run at once in one host machine, default:8",default=8)
    parser.add_argument("-v","--version",action="version",version='%(prog)s 1.0')
    return parser.parse_args()

def getconfig(configfile):
    d = {}
    with open(configfile) as fi:
        for line in fi:
            if line.strip() and not line.startswith("#"):
                k = line.split("=")[0]
                value = line.split("#")[0].partition("=")[-1]
                d[k] = value.strip()
    return d
    
def write_makeflow(mf,od,conf,pro,numjobs):   ##(name,od,configfile)
    if not os.path.exists(od): 
        print "%s is not the progect dir, please check!" %od
        sys.exit(1)
    od = os.path.abspath(od)
    # if os.path.exists(os.path.join(od,"results")):
        # print "%s dir exists, please remove!" %os.path.join(od,"results")
        # sys.exit(-1)
    # os.makedirs(os.path.join(od,"results"))
    if not os.path.exists(os.path.join(od,"results")):
        os.makedirs(os.path.join(od,"results"))
    mfile = open(os.path.join(od,mf),"w")
    mfile.write("CATEGORY=creat_result_makeflow\n")
    mfile.write(os.path.join(od,"results","result_makeflow : ") + os.path.abspath(conf) + "\n")
    mfile.write("\tperl /lustre/work/yongdeng/software/python_scripts/get.makeflowresult.makeflow.pl -od %s -config %s -name %s.tmp &> %s && mv %s %s\n\n"%(od,conf,mf,os.path.join(od,"results",mf+".tmp.log"),os.path.join(od,"%s.tmp"%mf),os.path.join(od,"results","result_makeflow")))
    confdict = getconfig(conf)
    abbr = confdict["species_abbreviation"]
    species = "_".join(confdict["species"].split("_")[:2])
    fa = os.path.basename(confdict["fa"])
    gtf = os.path.basename(confdict["gtf"]).partition(".gtf")[0]+".gtf"
    gs = confdict["rep"].replace(";","").replace("("," ").replace(")"," ")
    vs = confdict["vs"].replace(";"," ")
    moduels = confdict["moduels"].split(";")
    tm = ["cleandata","align","cufflinks","cuffnorm","cuffdiff","snp","noveltranscripts","gokegg","coexpression","propro","cluster","asprofile"]
    new_modules = []
    for i in tm:
        if i in moduels:
            new_modules.append(i)
    #new_modules = [i for i in moduels if i in tm]
    new_modules = re.sub("\W"," ",str(new_modules))
    res = os.path.join(od,"results")
    os.system( "rm -fr " + os.path.join(od,"results","result_makeflow.out ") + os.path.join(od,"results","result_makeflow.err") )
    mfile.write("CATEGORY=do_makeflow\n")
    mfile.write(os.path.join(od,"results","result_makeflow.out ") + os.path.join(od,"results","result_makeflow.err : ") + os.path.join(od,"results","result_makeflow\n") )
    mfile.write("\tmakeflow -j %d "%numjobs + os.path.join(od,"results","result_makeflow") + " > %s 2> %s\n\n"%(os.path.join(od,"results","result_makeflow.out"),os.path.join(od,"results","result_makeflow.err")))
    mfile.write("CATEGORY=get_docx\n")
    mfile.write(os.path.join(od,"results",pro+"report.docx : ") + os.path.join(od,"results","result_makeflow.out ") +  os.path.join(od,"results","result_makeflow.err\n"))
    cmd = "python /lustre/work/yongdeng/software/python_scripts/makedoc.py -abbr " + abbr +" -species " + species + " -fa " + fa + " -gtf " + gtf + " -gs " + re.sub(" +"," ",gs.strip()) + " -vs " + re.sub(" +"," ",vs.strip()) + " -p " + pro + " -m " + re.sub(" +"," ",new_modules.strip()) + " -o " + os.path.join(od,"results",pro+"report.docx ") + "-res " + os.path.join(od,"results")
    cmd += " > %s 2> %s\n\n" %(os.path.join(od,"results","docx.out"),os.path.join(od,"results","docx.err"))
    mfile.write("\t" + cmd)
    mfile.close()

def main():
    args = argsParse()
    if os.path.exists(os.path.join(args.od,args.name)):
        sys.stderr.write("%s file exists, please used a new name.\n" %args.name)
        sys.exit(-1)
    write_makeflow(args.name,args.od,args.configfile,args.project_num,args.max_jobs)
    p = subprocess.Popen('nohup makeflow -T sge --log-verbose %s'%args.name,shell=True,stdout = sys.stdout, stderr=sys.stderr )
    p.wait()
    
if __name__ == "__main__":
    main()
    
