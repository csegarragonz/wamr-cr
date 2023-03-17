FROM csegarragonz/dotfiles:0.2.0 as dotfiles
FROM csegarragonz/wasm-micro-runtime-base:main

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        clangd-13 \
        clang-format-13 \
        clang-tidy-13 \
        gdb \
        git

# Configure Neovim
COPY --from=dotfiles /neovim/build/bin/nvim /usr/bin/nvim
COPY --from=dotfiles /usr/local/share/nvim /usr/local/share/nvim
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    && mkdir -p ~/.config/nvim/ \
    && ln -sf ~/dotfiles/nvim/init.vim ~/.config/nvim/init.vim \
    && ln -sf ~/dotfiles/nvim/after ~/.config/nvim/ \
    && ln -sf ~/dotfiles/nvim/syntax ~/.config/nvim/ \
    && nvim +PlugInstall +qa \
    && nvim +PlugUpdate +qa

# Clone the dotfiles repo
RUN git clone https://github.com/csegarragonz/dotfiles ~/dotfiles

# Configure Bash
RUN ln -sf ~/dotfiles/bash/.bashrc ~/.bashrc \
    && ln -sf ~/dotfiles/bash/.bash_profile ~/.bash_profile \
    && ln -sf ~/dotfiles/bash/.bash_aliases ~/.bash_aliases
