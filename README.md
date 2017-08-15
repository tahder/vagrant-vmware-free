A free VMware provider for Vagrant
=========

A Vagrant provider is used to deploy your Vagrant boxes and configuration on some infrastructure. This plugin creates and manages vagrant deployments on VMware Workstation and Fusion. The work is not even mature enough to be called Alpha, though, so use at your own risk.

This plugin is not related in any way to Hashicorp or their VMware offering. Their plugin is probably much better, if you need VMware support for your project, you should use their product, as this thing barely works, and comes with no support.

Since this is a new project, a good knowledge of Vagrant plugins and VMware is required to use.

The code is provided under the MIT license (just like Vagrant).

Install
==

```
git clone https://github.com/dguerri/vagrant-vmware-free.git
cd vagrant-vmware-free
gem build vagrant-vmware-free.gemspec
vagrant plugin install ./vagrant-vmware-free-0.1.0.gem
```

How to use the provider
==
You need to build a box with the right provider (i.e. `vmware_free`).
Alternatively, you can use `dguerri/xenial64` from Vagrant Cloud.

Then, you need a `Vagrantfile`. For instance:
```
Vagrant.configure("2") do |config|
  (1..3).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.box = "dguerri/xenial64"
      node.vm.provision "shell",
        inline: "echo hello from node #{i}"
    end
  end
end
```

Finally, you need to run vagrant
```
~# vagrant up --provider=vmware_free --parallel
Bringing machine 'node-1' up with 'vmware_free' provider...
Bringing machine 'node-2' up with 'vmware_free' provider...
Bringing machine 'node-3' up with 'vmware_free' provider...
==> node-1: Importing base box 'dguerri/xenial64'...
==> node-2: Importing base box 'dguerri/xenial64'...
==> node-3: Importing base box 'dguerri/xenial64'...
==> node-3: Setting the name of the VM: test_node-3_1502838205
==> node-2: Setting the name of the VM: test_node-2_1502838205
==> node-1: Setting the name of the VM: test_node-1_1502838205
==> node-2: Booting VM...
2017-08-16T00:03:26.135| ServiceImpl_Opener: PID 66308
==> node-3: Booting VM...
==> node-2: Waiting for machine to boot. This may take a few minutes...2017-08-16T00:03:38.002| ServiceImpl_Opener: PID 66398

==> node-1: Booting VM...
2017-08-16T00:03:48.542| ServiceImpl_Opener: PID 66414
==> node-3: Waiting for machine to boot. This may take a few minutes...
==> node-1: Waiting for machine to boot. This may take a few minutes...
    node-3: SSH address: :22
    node-1: SSH address: :22
    node-2: SSH address: :22
    node-1: SSH username: vagrant
    node-3: SSH username: vagrant
    node-2: SSH username: vagrant
    node-1: SSH auth method: private key
    node-3: SSH auth method: private key
    node-2: SSH auth method: private key
    node-2: Warning: Authentication failure. Retrying...
    node-3: Warning: Authentication failure. Retrying...
    node-1: Warning: Authentication failure. Retrying...
    node-2:
    node-2: Vagrant insecure key detected. Vagrant will automatically replace
    node-2: this with a newly generated keypair for better security.
    node-2:
    node-2: Inserting generated public key within guest...
    node-2: Removing insecure key from the guest if it's present...
    node-2: Key inserted! Disconnecting and reconnecting using new SSH key...
    node-3: Warning: Authentication failure. Retrying...
    node-1: Warning: Authentication failure. Retrying...
==> node-2: Machine booted and ready!
==> node-2: Running provisioner: shell...
    node-2: Running: inline script
==> node-2: hello from node 2
    node-3:
    node-3: Vagrant insecure key detected. Vagrant will automatically replace
    node-3: this with a newly generated keypair for better security.
    node-3:
    node-3: Inserting generated public key within guest...
    node-3: Removing insecure key from the guest if it's present...
    node-1: Warning: Authentication failure. Retrying...
    node-3: Key inserted! Disconnecting and reconnecting using new SSH key...
==> node-3: Machine booted and ready!
==> node-3: Running provisioner: shell...
    node-3: Running: inline script
==> node-3: hello from node 3
    node-1:
    node-1: Vagrant insecure key detected. Vagrant will automatically replace
    node-1: this with a newly generated keypair for better security.
    node-1:
    node-1: Inserting generated public key within guest...
    node-1: Removing insecure key from the guest if it's present...
    node-1: Key inserted! Disconnecting and reconnecting using new SSH key...
==> node-1: Machine booted and ready!
==> node-1: Running provisioner: shell...
    node-1: Running: inline script
==> node-1: hello from node 1
```

Note
==

Currently, this provider won't support parallel 'UPs'.

At least for Fusion, do not open VMWare GUI while using Vagrant. Otherwise you will get a nice stack trace (with error code from Vix == 15)
