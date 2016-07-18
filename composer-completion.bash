#!/bin/bash
# Bit of shell completion for composer packages
# Thanks to https://debian-administration.org/article/317/An_introduction_to_bash_completion_part_2
#

_composer()
{
    local current previous dashopts allopts
    COMPREPLY=()
    current="${COMP_WORDS[COMP_CWORD]}"
    previous="${COMP_WORDS[COMP_CWORD-1]}"

    # dash options
    dashopts="-h -q -V -n -d -v -vv -vvv --help --verbose --quiet --version"

    # only show the useful commands. they can get to the rest w/ plan composer or --help
    allopts="clear-cache config diagnose dump-autoload help home install \
    list outdated remove require search self-update show status suggests update validate"

    # Args we want to complete
    case "${previous}" in
      # requires
      "require" )
        local reqOpts="--dev"
            COMPREPLY=( $(compgen -W "${reqOpts}" -- ${current}) )

        return 0
      ;;

      # updates
      "update" | "remove" )
        local packages="--dev "
        packages+=$(getPackages 'require')

        COMPREPLY=( $(compgen -W "${packages}" -- ${current}) )

        return 0
      ;;

      # --dev
      "--dev" )
        local pkgs=$(getPackages 'require-dev')
          COMPREPLY=( $(compgen -W "${pkgs}" -- ${current}) )

        return 0
      ;;
    esac

    # Hyphenated string
    if [[ ${current} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${dashopts}" -- ${current}) )
    # Empty catch-all
    else
        COMPREPLY=( $(compgen -W "${allopts}" -- ${current}) )
    fi

    # okay exit code
    return 0
}

# Bit o' hacky greppage to sniff packages in the composer file
function getPackages() {
  if [ -f composer.json ]; then
    local packages=()
    for package in $(awk "/\"$1\"/{f=1;next} /\}/{f=0} f" composer.json | sed -e 's/:.*//' | sed -e 's/"//g')
    do
      packages+=($package)
    done
  fi

  echo "${packages[@]}"
}

complete -F _composer composer
