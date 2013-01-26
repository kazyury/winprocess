#!ruby -Ks

require 'win32ole'
require 'Date'

class ProcessList
  def initialize()
    @wmi=WIN32OLE.connect("winmgmts://")
    # リストから除外するプロセス名のリスト
    @whitelist=['System Idle Process',
      'System',
      'smss.exe',
      'csrss.exe',
      'winlogon.exe',
      'services.exe',
      'alg.exe',
      'ApacheMonitor.exe',
      'avgchsvx.exe',
      'avgcsrvx.exe',
      'avgemc.exe',
      'avgnsx.exe',
      'avgrsx.exe',
      'avgtray.exe',
      'avgwdsvc.exe',
      'cmd.exe',
      'conime.exe',
      'explorer.exe',
      'firefox.exe',
      'gvim.exe',
      'IObit SmartDefrag.exe',
      'Ktp.exe',
      'lsass.exe',
      'plugin-container.exe',
      'SOUNDMAN.EXE',
      'spoolsv.exe',
      'svchost.exe',
      'taskmgr.exe',
      'TClock.exe',
      'thgtaskbar.exe',
      'tomcat5w.exe',
      'vimrun.exe',
      'VTTimer.exe',
      'winprocess_tcheck.exe',
      'wmiprvse.exe']
  end

  def list_process
    ret=[]
    @wmi.ExecQuery("select * from win32_process").each do |pr|
      buf={}
      buf[:name]=pr.name
      buf[:creationdate]=pr.creationdate
      ret.push buf
    end
    ret
  end

  def filter(processes)
    processes.find_all{|x| ! @whitelist.include?(x[:name]) }
  end

  def format(prc)
    sprintf("name [%-20s] start from [%25s]",prc[:name],prc[:creationdate])
  end

  def start
    today=Date.today.to_s
    File.open("#{today}.process_monitor.log",'a') do |out|
      loop do
        out.puts Time.now.to_s
        filter(list_process).each do |prc|
          out.puts format(prc)
        end
        out.flush
        sleep 60
      end
    end
  end


end


ProcessList.new.start
