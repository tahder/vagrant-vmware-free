module VagrantPlugins
  module ProviderVMwareFree
    module Action
      class WaitForNetwork
        include VagrantPlugins::ProviderVMwareFree::Driver::VIX

        TIMEOUT = 120

        def initialize(app, env)
          @app = app
        end

        def call(env)
          vm_handle = env[:machine].provider.driver.vm_handle

          ip = nil
          timeout = TIMEOUT
          loop do
            handle = VixVM_ReadVariable(vm_handle, :VIX_VM_GUEST_VARIABLE, 'ip', 0, nil, nil)
            code, properties = wait_with_pointers(handle, [:VIX_PROPERTY_JOB_RESULT_VM_VARIABLE_STRING])
            Vix_ReleaseHandle(handle)

            raise VIXError, code: code if (code != 0)
            ipPtr = properties[:VIX_PROPERTY_JOB_RESULT_VM_VARIABLE_STRING].read_pointer
            ip = ipPtr.read_string

            break if !ip.empty? or timeout == 0
            timeout -= 2
            sleep(2)
          end
        end
      end
    end
  end
end
