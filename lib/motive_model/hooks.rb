MotionBlender.except

Dir[File.expand_path('../hooks/**/*.rb', __FILE__)].each do |file|
  require file
end
