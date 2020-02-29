perl -MFile::Find=find -MFile::Spec::Functions -lwe 'find { wanted => sub { print canonpath $_ if /\.pm\z/ }, no_chdir => 1 }, @INC'
