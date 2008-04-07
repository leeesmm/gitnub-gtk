module GitNub

	# Subclass of the ComboBox model
				
	class Branches < Gtk::ComboBox

		alias :active_branch :active_text

		def initialize
			super
			model = Gtk::ListStore.new(String)
		end

		# Populates the Combobox with the repos branches	
		def update(controller)
			model.clear
			controller.repository.branches.each do |branch| 
				itr = model.append
				itr[0] = branch.name
			end
		end
	end
end
