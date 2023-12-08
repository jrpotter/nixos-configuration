{ ... }:
{
  programs.bash = {
    initExtra = ''
      source ${./git-prompt.sh}
      PS1="\n\e[0;32m• ["                             # • [
      PS1+="\e[0;33m\s"                               # \s (shell)
      PS1+="\e[0;32m:"                                # :
      PS1+="\e[0;36m\h"                               # \h (host)
      PS1+='$(__git_ps1 "\e[0;32m:\e[0;35m%s\e[0m")'  # git
      PS1+="\e[0;32m:"                                # :
      PS1+='\e[0m\w'                                  # \w
      PS1+="\e[0;32m]"                                # ]
      export PS1="''${PS1}\e[0m\n$ "                  # $
    '';
  };
}
