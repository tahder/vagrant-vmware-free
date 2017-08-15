require 'log4r'
require 'securerandom'
require 'yaml'

module VagrantPlugins
  module ProviderVMwareFree
    module Driver
      class Fusion < Base
        include VagrantPlugins::ProviderVMwareFree::Util::VMX
        include VagrantPlugins::ProviderVMwareFree::Driver::VIX

        INVENTORY = File.join(ENV['HOME'], '.vagrant.d', 'vmware.yml')

        attr_reader :vmx_path
        attr_reader :vm_handle

        def initialize(uuid)
          super(uuid)
          @logger = Log4r::Logger.new('vagrant::provider::vmware-free::fusion')
          @uuid = uuid

          @host_handle = get_host_handle

          # Create inventory file, if doesn't exist
          File.open(INVENTORY, "w") { |f| f.write('--- {}')} unless File.exists?(INVENTORY)

          if @uuid
            read_vms.each do |k, v|
              @vmx_path = v[:config] if k == uuid
            end
            @vm_handle = get_vm_handle(@host_handle, @uuid)
          end

        end

        def import(vmx_file, dest_file)
          box_handle = open_vmx(@host_handle, vmx_file)
          jobHandle = VixVM_Clone(box_handle, :VIX_INVALID_HANDLE, :VIX_CLONETYPE_LINKED, dest_file, 0, :VIX_INVALID_HANDLE, nil, nil)
          code, values = wait(jobHandle)
          Vix_ReleaseHandle(jobHandle)

          raise VIXError, "VixError: #{code}" if (code != 0)
          new_uuid = SecureRandom.uuid

          File.open(INVENTORY, "r+b") do |f|
            f.flock(File::LOCK_EX)
            inventory = YAML.load(f.read)
            inventory[new_uuid] = { config: dest_file }
            f.rewind
            f.write(inventory.to_yaml)
          end

          new_uuid
        end

        def delete
          jobHandle = VixVM_Delete(@vm_handle, :VIX_VMDELETE_DISK_FILES, nil, nil)
          code, values = wait(jobHandle)
          Vix_ReleaseHandle(jobHandle)
          raise VIXError, code: code if (code != 0)

          File.open(INVENTORY, "r+b") do |f|
            f.flock(File::LOCK_EX)
            inventory = YAML.load(f.read)
            inventory.delete @uuid
            f.rewind
            f.write(inventory.to_yaml)
          end

          nil
        end

        def resume(mode='headless')
          start(mode)
        end

        def vm_exists?(uuid)
          read_vms.each do |k, v|
            return true if k == uuid
          end

          false
        end

        # Follwing methods are stubs for now

        def read_vms
          inventory = nil
          File.open(INVENTORY, "rb") do |f|
            f.flock(File::LOCK_SH)
            inventory = YAML.load(f.read)
          end

          inventory
        end

        def set_value(key, value)
          vmx = vmx_parse(@vmx_path)
          vmx[key] = value
          vmx_save(@vmx_path, vmx)
          nil
        end

        def set_name(name)
          File.open(INVENTORY, "r+b") do |f|
            f.flock(File::LOCK_EX)
            inventory = YAML.load(f.read)
            inventory[@uuid]['name'] = name
            f.rewind
            f.write(inventory.to_yaml)
          end

          set_value('displayName', name)
        end

        def clear_forwarded_ports
        end

        def ip_address
          if @ip_address.nil? or @ip_address.empty?
            read_guest_ip
          end

          @ip_address
        end

        def read_guest_ip
          handle = VixVM_ReadVariable(vm_handle, :VIX_VM_GUEST_VARIABLE, 'ip', 0, nil, nil)
          code, properties = wait_with_pointers(handle, [:VIX_PROPERTY_JOB_RESULT_VM_VARIABLE_STRING])
          Vix_ReleaseHandle(handle)

          raise VIXError, code: code if (code != 0)
          ipPtr = properties[:VIX_PROPERTY_JOB_RESULT_VM_VARIABLE_STRING].read_pointer
          @ip_address = ipPtr.read_string
        end

        def read_forwarded_ports
          {}
        end

        def read_used_ports
          {}
        end

        def clear_shared_folders
        end

        def share_folders(folders)
        end

        def start(mode)
          if mode == 'gui'
            mode = :VIX_VMPOWEROP_LAUNCH_GUI
          else
            mode = :VIX_VMPOWEROP_NORMAL
          end

          jobHandle = VixVM_PowerOn(@vm_handle, :VIX_VMPOWEROP_NORMAL, :VIX_INVALID_HANDLE, nil, nil)
          code, values = wait(jobHandle)
          Vix_ReleaseHandle(jobHandle)
          raise VIXError, code: code if (code != 0)
          nil
        end

        def halt
          code, values = wait(VixVM_PowerOff(@vm_handle, :VIX_VMPOWEROP_NORMAL, nil, nil))
        end

        def read_state
          code, state = get_properties(@vm_handle, [:VIX_PROPERTY_VM_POWER_STATE])
          state = state[:VIX_PROPERTY_VM_POWER_STATE]

          raise VIXError, "VixError: #{code}" if (code != 0)
          @logger.debug("VM_POWER_STATE: #{state}")

          states_enum = VIX.enum_type(:VixPowerState)

          if state & states_enum[:VIX_POWERSTATE_POWERED_OFF] != 0
            :poweroff
          elsif state & states_enum[:VIX_POWERSTATE_POWERED_ON] != 0
            :running
          elsif state & states_enum[:VIX_POWERSTATE_SUSPENDED] != 0
            :saved
          elsif state & states_enum[:VIX_POWERSTATE_SUSPENDING] != 0
            :saving
          elsif state & states_enum[:VIX_POWERSTATE_POWERING_ON] != 0
            :booting
          else
            false
          end
        end

        protected

        def get_host_handle
          @logger.debug('Connecting to VIX...')
          jobHandle = VixHost_Connect(:VIX_API_VERSION, :VIX_SERVICEPROVIDER_VMWARE_WORKSTATION,
                                       '', 0, '', '', 0, :VIX_INVALID_HANDLE, nil, nil)
          code, values = wait(jobHandle, [:VIX_PROPERTY_JOB_RESULT_HANDLE])
          Vix_ReleaseHandle(jobHandle)

          raise VIXError, code: code if (code != 0)

          values[:VIX_PROPERTY_JOB_RESULT_HANDLE]
        end

        def get_vm_handle(host_handle, uuid)
          return nil if !uuid
          return nil if !vm_exists?(uuid)
          open_vmx(host_handle, @vmx_path)
        end

        def open_vmx(host_handle, vmx_path)
          jobHandle = VixHost_OpenVM(host_handle, vmx_path, :VIX_VMOPEN_NORMAL, :VIX_INVALID_HANDLE, nil, nil)
          code, values = wait(jobHandle, [:VIX_PROPERTY_JOB_RESULT_HANDLE])
          Vix_ReleaseHandle(jobHandle)

          raise VIXError, code if (code != 0)

          values[:VIX_PROPERTY_JOB_RESULT_HANDLE]
        end
      end
    end
  end
end
