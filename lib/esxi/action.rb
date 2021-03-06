require "vagrant"
require "vagrant/action/builder"

module VagrantPlugins
  module ESXi
    module Action
      include Vagrant::Action::Builtin

      # Vagrant commands
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsRunning do |env, b2|
            if [:result]
                b2.use PowerOff
                next
            end
          end
          b.use Destroy
        end
      end

      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end
            
            b2.use Call, IsRunning do |env, b3|
              if !env[:result]
                b3.use MessageNotRunning
                next       
              end
              
              b3.use Provision
              b3.use SyncFolders 
            end        
          end
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end
            
            b2.use Call, IsRunning do |env, b3|
              if !env[:result]
                b3.use MessageNotRunning
                next
              end
              
              b3.use SSHExec
            end
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end
            
            b2.use Call, IsRunning do |env, b3|
              if !env[:result]
                b3.use MessageNotRunning
                next
              end
              
              b3.use SSHRun
            end
          end
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if env[:result]
              b2.use MessageAlreadyCreated
              next
            end

            b2.use Create
          end
          b.use Call, IsRunning do |env, b2|
            if !env[:result]
              b2.use PowerOn
            end
          end
          b.use Provision          
          b.use SyncFolders          
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end
            
            b2.use Call, IsRunning do |env, b3|
              if !env[:result]
                b3.use MessageNotRunning
                next
              end
              
              b3.use PowerOff
            end
          end
        end
      end

      # ESXi specific actions
      def self.action_get_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use GetState
        end
      end

      def self.action_get_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use GetSshInfo
        end
      end

      # autoload
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :Create, action_root.join("create")
      autoload :Destroy, action_root.join("destroy")
      autoload :GetSshInfo, action_root.join("get_ssh_info")
      autoload :GetState, action_root.join("get_state")
      autoload :IsCreated, action_root.join("is_created")
      autoload :IsRunning, action_root.join("is_running")
      autoload :MessageAlreadyCreated, action_root.join("message_already_created")
      autoload :MessageNotCreated, action_root.join("message_not_created")
      autoload :MessageNotRunning, action_root.join("message_not_running")
      autoload :PowerOff, action_root.join("power_off")
      autoload :PowerOn, action_root.join("power_on")
      autoload :SyncFolders, action_root.join("sync_folders")
    end
  end
end
