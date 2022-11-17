---
title: Vim Kuberetes YAML Support
weight: 9988
description: Get Kubernetes resource autocompletion and validation in Vim.
date: 2020-01-06
images:
- https://octetz.s3.us-east-2.amazonaws.com/title-card-vim-k8s-support.png
---

# Vim Kuberetes YAML Support

Do you write YAML manifests for Kubernetes in vim? Have you also spent
countless time determining where in the spec a field belongs? Or perhaps you
want a quick reminder about the difference between `args` and `command`?
Good news! You can easily link vim to the
[yaml-language-server](https://github.com/redhat-developer/yaml-language-server)
to get completion, validation and more. In this post we’ll explore how to setup
a language server client to take advantage of this.

{{< yblink eSAzGx34gUE >}}

## Language Server

Language servers provide programming language features to editors and IDEs by
allowing communication over the Language Server Protocol (LSP). This approach is
exciting because it enables 1 implementation to feed a multitude of editors and
IDEs.  I previously did a
[post](https://octetz.com/docs/2019/2019-04-24-vim-as-a-go-ide) on
[gopls](https://github.com/golang/tools/blob/master/gopls/doc/user.md) the
golang language server and how it can also be used in
[vim](octetz.com/docs/2019/2019-04-24-vim-as-a-go-ide/). For Kubernetes YAML
completion the flow is similar.

{{< img src="https://octetz.s3.us-east-2.amazonaws.com/lsp-kube-vim.png"
class="center" width="600" >}}

For vim to operate as described, you need a language server client. The two ways
I am aware of are
[LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim) and
[coc.vim](https://github.com/autozimu/LanguageClient-neovim). In this post, I’ll
be showing the coc.vim plugin as it is the most popular plugin at the time of
this writing. You can install coc.vim using
[vim-plug](https://github.com/junegunn/vim-plug).

```
" Use release branch (Recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Or build from source code by use yarn: https://yarnpkg.com
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
```

To run coc (and eventually the yaml-language-server), you need node.js
installed.

```
curl -sL install-node.now.sh/lts | bash
```

With coc.vim setup, install the coc-yaml server extension from within vim.

```
:CocInstall coc-yaml
```



{{< img src="https://octetz.s3.us-east-2.amazonaws.com/coc-yaml-install.gif" class=“center" >}}

Lastly, you’ll likely want to start with the coc-vim config mappings found in
the [example
configuration](https://github.com/neoclide/coc.nvim#example-vim-configuration).
These enable things like `ctrl + space` to trigger autocompletion.

## Configure yaml-language-server Detection

In order for coc to use the yaml-language-server, you must tell it to load the
Kubernetes schema when editing YAML files. You can do this by modifying the
coc-config.

```
:CocConfig
```

In the config file, add `kubernetes` for all `yaml` files. Below you can see my
configuration, which includes a golang configuration.

```
{
  "languageserver": {
      "golang": {
        "command": "gopls",
        "rootPatterns": ["go.mod"],
        "filetypes": ["go"]
      }
  },

  "yaml.schemas": {
      "kubernetes": "/*.yaml"
  }

}
```

`kubernetes` is a reserved field that tells the language server to load the
Kubernetes schema URL from [this constant
variable](https://github.com/redhat-developer/yaml-language-server/blob/18bd5693ef8a2aeb23e2172be481edc41809f718/src/server.ts#L32).
`yaml.schemas` can be expanded to add support for other schemas, [check out the
schema association
docs](https://github.com/redhat-developer/yaml-language-server#more-examples-of-schema-association)
for more details.

Now you can create a YAML file and start using the autocompletion. Based on your
context, hitting `ctrl + space` (or your equivalent vim binding) should bring up
available fields and documentation.



{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/vim-yaml-pod-autocomplete-demo.gif"
class=“center" >}}

> ctrl + space works here because I have set `inoremap <silent><expr> <c-space>
> coc#refresh()`, if you haven’t, visit the [coc.nvim
> README](https://github.com/neoclide/coc.nvim#example-vim-configuration) for an
> example configuration.

## Set Kubernetes API Version

At the time of this writing, yaml-language-server ships with the Kubernetes
1.14.0 schemas. I’m unaware of a way to dynamically choose the schema, although
I have opened [a GitHub issue inquiring about
it](https://github.com/redhat-developer/yaml-language-server/issues/211).
Luckily, since the language server is written in typescript, it is fairly easy
to modify if you know where the `server.ts` file lives.

To determine where it is installed on your machine, simply open up a YAML file
with vim and check your processes for `yaml-language-server`.

```
ps aux | grep -i yaml-language-server
```

```
joshrosso         2380  45.9  0.2  5586084  69324   ??  S     9:32PM   0:00.43 /usr/local/Cellar/node/13.5.0/bin/node /Users/joshrosso/.config/coc/extensions/node_modules/coc-yaml/node_modules/yaml-language-server/out/server/src/server.js --node-ipc --node-ipc --clientProcessId=2379
joshrosso         2382   0.0  0.0  4399352    788 s001  S+    9:32PM   0:00.00 grep -i yaml-language-server
```

> The above process, 2380, is only active because an instance of vim is editing
> a YAML file.

As you can see, mine is located at
`/Users/joshrosso/.config/coc/extensions/node_modules/coc-yaml/node_modules/yaml-language-server/out/server/src/server.js`.
You can edit the file and update the `KUBERNETES_SCHEMA_URL` variable to, for
example, 1.17.0.

```
// old 1.14.0 schema
//exports.KUBERNETES_SCHEMA_URL = "https://raw.githubusercontent.com/garethr/kubernetes-json-schema/master/v1.14.0-standalone-strict/all.json";
// new 1.17.0 schema in instrumenta repo
exports.KUBERNETES_SCHEMA_URL = "https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.17.0-standalone-strict/all.json";
```

Depending on your version of `coc-yaml`, the variable's location may vary. Do
note that I have changed the repo from `garethr` to `instrumenta`. It appears
`garethr` has started maintaining the schemas in that repo.

As a test, you can validate a field shows up that wasn’t previously available.
For me, I can check for
[startupProbe](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes),
which wasn’t available in the 1.14 schema.



{{< img
src="https://octetz.s3.us-east-2.amazonaws.com/vim-startup-probe-yaml.png"
class=“center" >}}

## Summary

I hope you’re as stoked about this feature set as me! Happy YAMLing :). Be sure
to checkout the following repos for a deeper dive into the tools used in this
post.

* coc-vim: https://github.com/neoclide/coc.nvim
* coc-yaml: https://github.com/neoclide/coc-yaml
