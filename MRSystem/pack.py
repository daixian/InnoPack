# coding: utf-8
import subprocess
import os
import urllib
from urllib import request
import sys
import tarfile
import zipfile
import shutil
import getopt


def extract_zip(zfile_path, unzip_dir):
    '''
    function:解压
    params:
        zfile_path:压缩文件路径
        unzip_dir:解压缩路径
    description:
    '''
    try:
        if not os.path.exists(unzip_dir):
            os.makedirs(unzip_dir)
        # with zipfile.ZipFile(zfile_path) as zfile:
        #     zfile.extractall(path=unzip_dir) 直接all会中文乱码
        with zipfile.ZipFile(zfile_path, 'r') as zf:
            for fn in zf.namelist():
                right_fn = os.path.join(unzip_dir, fn.encode(
                    'cp437').decode('gbk'))  # 将文件名正确编码
                if (right_fn.endswith('/')):
                    if os.path.exists(right_fn):
                        shutil.rmtree(right_fn)
                    os.makedirs(right_fn)
                else:
                    with open(right_fn, 'wb') as output_file:  # 创建并打开新文件
                        with zf.open(fn, 'r') as origin_file:  # 打开原文件
                            shutil.copyfileobj(
                                origin_file, output_file)  # 将原文件内容复制到新文件
    except zipfile.BadZipFile as e:
        print(zfile_path+"unzip error"+e)


def extract_tar(tar_path, target_path):
    '''
    function:解压
    params:
        tar_path:压缩文件路径
        target_path:解压缩路径
    description:
    '''
    try:
        tar = tarfile.open(tar_path, "r:gz")
        file_names = tar.getnames()
        for file_name in file_names:
            tar.extract(file_name, target_path)
        tar.close()
    except:
        print(tar_path+"unzip error")


# 用来记一个状态,输出日志行数太多
report_lastper = -1


def progress_bar(name, total, progress):
    # 如果已经结束过了,那么就不画进度了
    if report_lastper == total:
        return

    barLength, status = 40, ""
    progress = float(progress) / float(total)
    if progress < 0:
        return
    if progress >= 1.:
        progress, status = 1, "\r\n"  # "\r\n"
    block = int(round(barLength * progress))
    text = "\r{} [{}] {:.2f}% {}".format(name,
                                         "#" * block + "-" *
                                         (barLength - block), round(progress * 100, 2),
                                         status)
    sys.stdout.write(text)
    sys.stdout.flush()


def request_report(bcount, bsize, size):
    '''输出一个下载进度
    params:
        bcount:已下载的块数量
        bsize:块大小
        size:文件总大小
    '''
    if size == -1:  # 可能是不支持进度那么就是-1
        return
    per = 100*bcount*bsize/size
    per = round(per, 2)
    if per > 100:
        per = 100
    global report_lastper
    if per - report_lastper > 1 or per == 100:
        progress_bar("download:", 100, per)
        report_lastper = per


def download_with_cache(in_url, in_filepath):
    '''下载前判断一次是否文件已经缓存了'''
    if not os.path.exists(os.path.dirname(in_filepath)):
        os.makedirs(os.path.dirname(in_filepath))
    if os.path.exists(in_filepath) and os.path.isfile(in_filepath):
        # 如果本地存在缓存那么就不下载了
        print(in_filepath+" [cached]")
    else:
        print(in_url+" -> "+in_filepath)
        # 有的系统不能\r,所以就先不输出进度了
        global report_lastper
        report_lastper = -1
        request.urlretrieve(in_url, in_filepath, request_report)
        # request.urlretrieve(in_url, in_filepath)
    print(in_filepath+" [done]")


def run_inno_script():
    # 当前脚本路径
    curPyPath = os.path.abspath(__file__)
    # 当前脚本文件夹路径
    curPyDirPath = os.path.abspath(os.path.dirname(curPyPath))
    # inno程序路径
    innoPath = os.path.join(curPyDirPath, "Inno Setup 5", "ISCC.exe")
    # inno脚本路径
    innoScriptPath = os.path.join(curPyDirPath, "MRSystem", "inno.iss")
    # 命令
    cmd = '"%s" "%s"' % (innoPath, innoScriptPath)

    print(subprocess.call(cmd, shell=True))


def main(argv):
    # 当前脚本路径
    curPyPath = os.path.abspath(__file__)
    # 当前脚本文件夹路径
    curPyDirPath = os.path.abspath(os.path.dirname(curPyPath))
    downloadFile = os.path.join(curPyDirPath, "v1.0.0.0.zip")
    # 下载要打成安装包的文件
    download_with_cache(
        "http://mr.xuexuesoft.com:8010/soft/MRSystem/v1.0.0.0.zip", downloadFile)
    # 解压缩
    extractDir = os.path.join(curPyDirPath, "MRSystem")
    extract_zip(downloadFile, extractDir)
    targetFilesDir = os.path.join(curPyDirPath, "MRSystem", "MRSystem")
    if os.path.exists(targetFilesDir):
        shutil.rmtree(targetFilesDir)
    # 里面的文件夹是MRSystem\v1.0.0.0
    os.renames(extractDir + os.path.sep + "v1.0.0.0", targetFilesDir)
    # 下载inno软件
    innoZipFile = os.path.join(curPyDirPath, "Inno Setup 5.zip")
    download_with_cache(
        "https://github.com/daixian/daixian.github.io/raw/master/assets/files/inno/Inno%20Setup%205.zip", innoZipFile)
    if os.path.exists(curPyDirPath + os.path.sep + "Inno Setup 5"):
        shutil.rmtree(curPyDirPath + os.path.sep + "Inno Setup 5")
    extract_zip(innoZipFile, curPyDirPath)
    # 下载.net
    dlFile = os.path.join(curPyDirPath, "MRSystem", "Runtime",
                          "NDP452-KB2901907-x86-x64-AllOS-ENU.exe")
    download_with_cache(
        "https://github.com/daixian/daixian.github.io/raw/master/assets/files/inno/Runtime/NDP452-KB2901907-x86-x64-AllOS-ENU.exe", dlFile)
    # 下载vcrt2015
    dlFile = os.path.join(curPyDirPath, "MRSystem",
                          "Runtime", "vc_redist.x64.exe")
    download_with_cache(
        "https://github.com/daixian/daixian.github.io/raw/master/assets/files/inno/Runtime/vc_redist.x64.exe", dlFile)
    # 运行打包脚本
    run_inno_script()


if __name__ == "__main__":
    main(sys.argv[1:])
