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
    dashopts="-h -q -V -n -d -v -vv -vvv --help --verbose --quiet --version --no-ansi --ansi \
    --no-interaction --profile --no-plugins --working-dir"

    # all commands
    allopts="about archive browse clear-cache clearcache  config create-project \
    depends diagnose dump-autoload dumpautoload exec global help home info \
    init install licenses list outdated prohibits remove require run-script \
    search self-update selfupdate show status suggests update validate why why-not"

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
        packages+=`require`

        COMPREPLY=( $(compgen -W "${packages}" -- ${current}) )

        return 0
      ;;

      # --dev
      "--dev" )
          COMPREPLY=( $(compgen -W "`requireDev`" -- ${current}) )

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

function require() {
  if [ -f composer.json ]; then
    local packages=()
    for package in $(awk '/\"require\"/{f=1;next} /\}/{f=0} f' composer.json | sed -e 's/:.*//' | sed -e 's/"//g')
    do
      packages+=($package)
    done
  fi

  echo "${packages[@]}"
}

function requireDev() {
  if [ -f composer.json ]; then
    local packages=()
    for package in $(awk '/\"require-dev\"/{f=1;next} /\}/{f=0} f' composer.json | sed -e 's/:.*//' | sed -e 's/"//g')
    do
      packages+=($package)
    done
  fi

  echo "${packages[@]}"
}

function testComposerFile() {
  if [ ! -f composer.json ]; then
    echo ""
    echo "No composer.json in PWD"
    echo ""

    return false
  fi

  return true
}

complete -F _composer composer
