#!/usr/bin/env ruby

require 'pathname'
require 'md5'
require 'open-uri'
require 'cgi'
require 'libglade2'
require 'webkit'

$: << Pathname.new(File.dirname(__FILE__) + '/../').realpath

require 'grit/lib/grit'
require 'gitnub/commits'
require 'gitnub/branches'
require 'gitnub/commit_view'

module GitNub
	class ApplicationController
	
		include GetText
	
	  attr :glade
	  attr_accessor :repository, :active_commits
		attr_accessor :branches, :commits, :commit_view
		attr_accessor :previous_button, :latest_button, :next_button
	
	  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
	    bindtextdomain(domain, localedir, nil, "UTF-8")
	    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) { |handler| method(handler) }
	
			@branches = @glade['branches']
			@commits = @glade['commits']
			@commit_view = @glade['commit_view']
			@previous_button = @glade['previous_button']
			@latest_button = @glade['latest_button']
			@next_button = @glade['next_button']

			# Connect some signals
			@branches.signal_connect('changed') { @commits.update(self) }
			@previous_button.signal_connect('clicked') { @commits.page_commits('previous', self) }
			@latest_button.signal_connect('clicked') { @commits.page_commits('latest', self) }
			@next_button.signal_connect('clicked') { @commits.page_commits('next', self) }
			@commits.tree_view.signal_connect('cursor_changed') { @commit_view.update(self) }

			# Finally set everything to go
			load_repository
			@branches.update(self)
			@branches.set_active(0)
			@commits.page_commits('latest', self)
	  end

		# Basic about window
		def on_about_activate(widget)
			Gnome::About.new("GitNub-GTK", "0.01", "Copyright (C) 2008 Russ Smith", "A Port of GitNub for OS X", ["Russ Smith"], ["Russ Smith"], nil).show
		end

		def on_window_delete_event(widget, arg0 = nil)
			Gtk.main_quit
			exit!
		end

		private

		# Load up the repository
		def load_repository
			pwd = Pathname.new(ENV['PWD'].nil? ? Dir.getwd : ENV['PWD'])
			begin
				@repository = Grit::Repo.new(pwd + `cd #{pwd} && git rev-parse --git-dir 2>/dev/null`.chomp)
			rescue Grit::InvalidGitRepositoryError
				puts "Not a vaid git repo."
				Gtk.main_quit
				exit!
			end
		end
	end
end
	
# Main program
PROG_PATH = File.join(Pathname.new(File.dirname(__FILE__)).realpath, "interface.glade")
PROG_NAME = "GitNub"
Gtk.init
GitNub::ApplicationController.new(PROG_PATH, nil, PROG_NAME)
Gtk.main
