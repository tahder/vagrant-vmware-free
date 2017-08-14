A free VMware provider for Vagrant
=========

A Vagrant provider is used to deploy your Vagrant boxes and configuration on some infrastructure. This plugin creates and manages vagrant deployments on VMware Workstaion and Fusion. The work is not even mature enough to be called Alpha, though, so use at your own risk.

This plugin is not related in any way to Hashicorp or their VMware offering. Their plugin is probably much better, if you need VMware support for your project, you should use their product, as this thing barely works, and comes with no support.

Since this is a new project, a good knowledge of Vagrant plugins and VMware is required to use.

The code is provided under the MIT license (just like Vagrant).

Install
==

```
git clone https://github.com/dguerri/vagrant-vmware-free.git
cd vagrant-vmware-free
gem build vagrant-vmware-free.gemspec
vagrant plugin install ./vagrant-vmware-free-0.0.2.gem
```

How to use the provider
==
You need to build a box with the right provider (i.e. `vmware_free`)

Then, you need a `Vagrantfile`. For instance:
```
Vagrant.configure("2") do |config|
  config.vm.box = "test-box"
end
```

Finally, you need to run vagrant
```
vagrant up --provider=vmware_free
```

Note
==

Currently, this provider won't support parallel 'ups'.

At least for Fusion, do not open vmware GUI while using vagrant. Otherwise you will get a nice stack trace (with error code from Vix == 15) 
