FROM ubuntu:xenial

RUN apt update && apt install -y software-properties-common && \
    add-apt-repository -y ppa:jonathonf/vim && \
    apt update && apt install -y build-essential openssh-server git vim zsh tmux curl unzip sudo && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L git.io/cli | L=peco/peco bash
RUN cd /tmp && curl -LO https://github.com/motemen/ghq/releases/download/v0.7.2/ghq_linux_amd64.zip && unzip ghq_linux_amd64.zip && cp /tmp/ghq /usr/bin
RUN curl -L https://raw.githubusercontent.com/git/git/master/contrib/diff-highlight/diff-highlight > /usr/local/bin/diff-highlight && chmod +x /usr/local/bin/diff-highlight

RUN groupadd -g 1000 kan && \
    useradd -g kan -G sudo -m -s /bin/zsh kan && \
    echo 'kan:${PASS}' | chpasswd

COPY ssh /home/kan/.ssh

RUN chown -R kan:kan /home/kan
RUN chmod 600 /home/kan/.ssh/id_rsa

USER kan

WORKDIR /home/kan

RUN GHQ_ROOT=~/src ghq get git@github.com:kan/dotfiles.git \
	&& ln -s ~/src/github.com/kan/dotfiles/zsh/.zshrc ~/.zshrc \
	&& ln -s ~/src/github.com/kan/dotfiles/zsh/.zshenv ~/.zshenv \
	&& ln -s ~/src/github.com/kan/dotfiles/vim/.vimrc ~/.vimrc \
	&& ln -s ~/src/github.com/kan/dotfiles/vim/.vim ~/.vim \
	&& ln -s ~/src/github.com/kan/dotfiles/git/gitconfig ~/.gitconfig \
	&& ln -s ~/src/github.com/kan/dotfiles/git/gitignore ~/.gitignore \
	&& ln -s ~/src/github.com/kan/dotfiles/tmux ~/.tmux.conf \
	&& cd ~/src/github.com/kan/dotfiles && git submodule init && git submodule update

RUN vim +PlugInstall +qall

CMD ["/bin/zsh"]
