require "bundler/gem_tasks"

if (Rake.application.top_level_tasks - Rake.application.tasks.map(&:name)).any?
  $:.unshift("/Library/RubyMotion/lib")
  require 'motion/project/template/ios'
  Bundler.require

  require 'motion-redgreen'
  require 'motion-stump'

  Motion::Project::App.setup do |app|
    app.name = 'MotiveModel'
    app.redgreen_style = :progress

    if app.spec_mode
      require File.join(app.specs_dir, 'helpers/_init')
    end
  end
end
