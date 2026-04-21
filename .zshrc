# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell-custom"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# Keep ls directory colors aligned with the Ghostty theme's main blue.
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"

alias dev='cd /Users/f.tesche/Documents/dev'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# secrets — keep ~/.env out of version control
[ -f "$HOME/.env" ] && source "$HOME/.env"

# bun completions
[ -s "/Users/f.tesche/.bun/_bun" ] && source "/Users/f.tesche/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# git-branch-desc: view or set a branch description (stored in .git/config per repo)
#   git-branch-desc                   - show current branch description
#   git-branch-desc "desc"            - set current branch description
#   git-branch-desc <branch>          - show named branch description
#   git-branch-desc <branch> "desc"   - set named branch description
git-branch-desc() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not a git repository"; return 1
  fi
  local branch
  if [[ $# -ge 1 ]] && git show-ref --verify --quiet "refs/heads/$1" 2>/dev/null; then
    branch="$1"; shift
  else
    branch=$(git rev-parse --abbrev-ref HEAD)
  fi
  if [[ $# -eq 0 ]]; then
    git config "branch.${branch}.description" 2>/dev/null || echo "(no description)"
  else
    git config "branch.${branch}.description" "$1"
    echo "Description set for '$branch'"
  fi
}

# git-history: browse recently worked-on branches with timestamps and descriptions, select to checkout
# ctrl-e: edit description of highlighted branch inline
git-history() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not a git repository"; return 1
  fi

  # Fetch all MR states upfront: one API call + one jq run → "branch\tstate" lines
  local _mr_map=""
  if [[ -n "$GITLAB_TOKEN" ]]; then
    local _remote _host _proj _enc
    _remote=$(git remote get-url origin 2>/dev/null)
    _host=$(echo "$_remote" | sed -E 's|^git@([^:]+):.*|\1|' | sed -E 's|^https?://([^/]+)/.*|\1|')
    _proj=$(echo "$_remote" | sed -E 's|\.git$||' | sed -E 's|^git@[^:]+:||' | sed -E 's|^https?://[^/]+/||')
    _enc=$(echo "$_proj" | sed 's|/|%2F|g')
    _mr_map=$(curl -sf -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
      "https://${_host}/api/v4/projects/${_enc}/merge_requests?per_page=100&order_by=updated_at" \
      2>/dev/null \
      | tr -d '\000-\010\013-\037' \
      | jq -r '.[] | "\(.source_branch)\t\(.state)"' 2>/dev/null)
  fi

  local branch
  branch=$(
    while IFS='|' read -r name timeago; do
      desc=$(git config "branch.${name}.description" 2>/dev/null)
      mr_tag=""
      if [[ -n "$_mr_map" ]]; then
        mr_state=$(awk -F'\t' -v b="$name" '$1==b{print $2; exit}' <<< "$_mr_map")
        case "$mr_state" in
          opened) mr_tag=$'\033[32m[open]  \033[0m' ;;
          merged) mr_tag=$'\033[35m[merged]\033[0m' ;;
          closed) mr_tag=$'\033[31m[closed]\033[0m' ;;
        esac
      fi
      suffix=""
      [[ -n "$mr_tag" ]] && suffix=$mr_tag
      [[ -n "$desc" && -n "$mr_tag" ]] && suffix+="  "$'\033[2m'"$desc"$'\033[0m'
      [[ -n "$desc" && -z "$mr_tag" ]] && suffix=$'\033[2m'"$desc"$'\033[0m'
      if [[ -n "$suffix" ]]; then
        printf "%s\t%-22s %-45s  %s\n" "$name" "$timeago" "$name" "$suffix"
      else
        printf "%s\t%-22s %s\n" "$name" "$timeago" "$name"
      fi
    done < <(git for-each-ref --sort=-committerdate refs/heads/ \
      --format='%(refname:short)|%(committerdate:relative)') |
    fzf --no-sort \
        --ansi \
        --delimiter=$'\t' \
        --with-nth=2 \
        --header='Select a branch  [ctrl-e: edit desc] [ctrl-y: YouTrack] [ctrl-o: GitLab MR]' \
        --prompt='branch> ' \
        --bind='ctrl-e:execute(
          name={1};
          cur=$(git config "branch.$name.description" 2>/dev/null);
          printf "\nBranch: %s\n" "$name" >/dev/tty;
          [ -n "$cur" ] && printf "Current: %s\n" "$cur" >/dev/tty;
          printf "New description (empty to cancel): " >/dev/tty;
          IFS= read -r d </dev/tty;
          [ -n "$d" ] && git config "branch.$name.description" "$d"
        )+reload(git for-each-ref --sort=-committerdate refs/heads/ --format="%(refname:short)|%(committerdate:relative)" | while IFS="|" read -r n t; do d=$(git config "branch.$n.description" 2>/dev/null); if [ -n "$d" ]; then printf "%s\t%-22s %-45s  \033[2m%s\033[0m\n" "$n" "$t" "$n" "$d"; else printf "%s\t%-22s %s\n" "$n" "$t" "$n"; fi; done)' \
        --bind='ctrl-y:execute(
          name={1};
          ticket=$(echo "$name" | grep -oE "PX-[0-9]+" | head -1);
          if [ -n "$ticket" ]; then
            open "https://youtrack-winning.dev.wocio.de/issue/$ticket";
          else
            printf "\nNo PX ticket found in branch: %s\n" "$name" >/dev/tty;
            read -k1 2>/dev/null || read -n1 2>/dev/null;
          fi
        )' \
        --bind='ctrl-o:execute(
          name={1};
          token="$GITLAB_TOKEN";
          if [ -z "$token" ]; then
            printf "\nGITLAB_TOKEN not set — export GITLAB_TOKEN=<your-token>\n" >/dev/tty;
            read -k1 2>/dev/null || read -n1 2>/dev/null;
          else
            remote_url=$(git remote get-url origin 2>/dev/null);
            host=$(echo "$remote_url" | sed -E "s|^git@([^:]+):.*|\1|" | sed -E "s|^https?://([^/]+)/.*|\1|");
            project=$(echo "$remote_url" | sed -E "s|\.git$||" | sed -E "s|^git@[^:]+:||" | sed -E "s|^https?://[^/]+/||");
            encoded=$(echo "$project" | sed "s|/|%2F|g");
            result=$(curl -sf -H "PRIVATE-TOKEN: $token" "https://${host}/api/v4/projects/${encoded}/merge_requests?source_branch=${name}" \
              | jq -r ".[0] | if . then (.web_url + \"|\" + .state + \"|\" + (.iid|tostring) + \"|\" + .title) else \"\" end");
            if [ -n "$result" ]; then
              mr_url=$(echo "$result" | cut -d"|" -f1);
              state=$(echo "$result" | cut -d"|" -f2);
              iid=$(echo "$result" | cut -d"|" -f3);
              title=$(echo "$result" | cut -d"|" -f4);
              printf "\nMR #%s [%s]: %s\n" "$iid" "$state" "$title" >/dev/tty;
              open "$mr_url";
            else
              printf "\nNo MR found for branch: %s — create one? [y/N] " "$name" >/dev/tty;
              read -k1 answer </dev/tty 2>/dev/null || read -n1 answer </dev/tty 2>/dev/null;
              printf "\n" >/dev/tty;
              if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
                open "https://${host}/${project}/-/merge_requests/new?merge_request[source_branch]=${name}";
              fi;
            fi;
          fi
        )' |
    cut -f1
  )

  if [[ -n "$branch" ]]; then
    git checkout "$branch"
  fi
}

# git-yeet: move uncommitted changes onto a new branch with a different base
#   git-yeet <new-branch>             - create <new-branch> from develop, apply changes there
#   git-yeet <new-branch> <base>      - create <new-branch> from <base>, apply changes there
git-yeet() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not a git repository"; return 1
  fi

  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: git-yeet <new-branch> [base-branch]"
    echo ""
    echo "Move uncommitted changes onto a new branch with a different base."
    echo ""
    echo "Arguments:"
    echo "  <new-branch>   Name of the new branch to create"
    echo "  [base-branch]  Branch to base the new branch on (default: develop)"
    echo ""
    echo "Examples:"
    echo "  git-yeet fix/PX-123-button-hover"
    echo "  git-yeet fix/PX-123-button-hover main"
    return 0
  fi

  local new_branch="${1}"
  local base_branch="${2:-develop}"

  if [[ -z "$new_branch" ]]; then
    echo "Usage: git-yeet <new-branch> [base-branch]"; return 1
  fi

  local changes
  changes=$(git status --porcelain 2>/dev/null)
  if [[ -z "$changes" ]]; then
    echo "No uncommitted changes to yeet"; return 0
  fi

  echo "Stashing changes..."
  git stash push -u -m "git-yeet: ${new_branch}" || return 1

  echo "Creating branch '${new_branch}' from '${base_branch}'..."
  if ! git checkout -b "${new_branch}" "${base_branch}"; then
    echo "Failed to create branch — restoring stash"
    git stash pop
    return 1
  fi

  echo "Applying changes..."
  if ! git stash pop; then
    echo "Conflicts detected — resolve them on '${new_branch}' and then: git stash drop"
    return 1
  fi

  echo "Yeeted changes to '${new_branch}' (based on '${base_branch}')"
}

# git-diff: interactively cycle through uncommitted changed files with fzf preview
git-diff() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not a git repository"; return 1
  fi

  local files
  files=$(git diff HEAD --name-only 2>/dev/null)
  if [[ -z "$files" ]]; then
    echo "No uncommitted changes"; return 0
  fi

  echo "$files" | fzf --preview 'git diff HEAD --color=always -- {}' \
                       --preview-window='right:70%:wrap' \
                       --header="Navigate changed files (tab to cycle)" \
                       --prompt="file> " \
                       --bind='enter:accept' \
                       --no-sort
}



# pwqa: rerun a QA Playwright spec by pasting a full failure line or a spec path
# pwqa: parse Playwright/GitLab logs and rerun matching tests using existing .env
pwqa() {
  emulate -L zsh
  setopt pipefail no_nomatch

  local repo="/Users/f.tesche/Documents/dev/webapp/playwright"
  local mode="run"
  local raw stdin_data line spec tag key
  local -a inputs pairs extra_args
  typeset -A seen

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run|--print)
        mode="print"
        shift
        ;;
      --headed|--ui|--debug|--workers=*)
        extra_args+=("$1")
        shift
        ;;
      --help)
        cat <<'USAGE'
Usage:
  pwqa '<single Playwright failure line>'
  pwqa 'line 1' 'line 2'
  pbpaste | pwqa
  pwqa --dry-run <<'EOF'
  ...full GitLab log...
  EOF
USAGE
        return 0
        ;;
      *)
        inputs+=("$1")
        shift
        ;;
    esac
  done

  if [[ ! -t 0 ]]; then
    stdin_data=$(cat)
  fi

  if (( ${#inputs[@]} )) && [[ -n "$stdin_data" ]]; then
    raw="${(j:\n:)inputs}"
    raw+=$'\n'
    raw+="$stdin_data"
  elif (( ${#inputs[@]} )); then
    raw="${(j:\n:)inputs}"
  else
    raw="$stdin_data"
  fi

  if [[ -z "$raw" ]]; then
    echo 'Usage: pwqa <Playwright failure line(s)> or pipe a full log into stdin.'
    return 1
  fi

  raw=$(printf '%s' "$raw" | perl -pe 's/\e\[[0-9;?]*[ -\/]*[@-~]//g')

  while IFS= read -r line; do
    spec=$(printf '%s\n' "$line" | perl -ne 'if (m{(\.output/bdd/.*?\.spec\.js)(?::\d+:\d+)?(?:\s+›|$)}) { print $1 }')
    [[ -z "$spec" ]] && continue

    tag=$(printf '%s\n' "$line" | grep -oE '@Q[0-9]+' | head -n1)
    key="${spec}|${tag}"

    if [[ -z "${seen[$key]}" ]]; then
      seen[$key]=1
      pairs+=("$key")
    fi
  done <<< "$raw"

  if (( ${#pairs[@]} == 0 )); then
    echo 'No Playwright spec paths found in input.'
    return 1
  fi

  echo 'Parsed targets:'
  local pair
  for pair in "${pairs[@]}"; do
    spec="${pair%%|*}"
    tag="${pair#*|}"
    if [[ -n "$tag" ]]; then
      echo "  - $spec ($tag)"
    else
      echo "  - $spec"
    fi
  done

  [[ "$mode" == "print" ]] && return 0

  (
    cd "$repo" || exit 1
    npx bddgen || exit $?

    for pair in "${pairs[@]}"; do
      spec="${pair%%|*}"
      tag="${pair#*|}"

      echo
      if [[ -n "$tag" ]]; then
        echo ">>> Running $spec with $tag"
        npx playwright test "$spec" -g "$tag" "${extra_args[@]}" || return $?
      else
        echo ">>> Running $spec"
        npx playwright test "$spec" "${extra_args[@]}" || return $?
      fi
    done
  )
}


alias e2e='pbpaste | pwqa --workers=1 --headed'


