#! /usr/bin/env ruby

require 'orocos'
require 'orocos/log'
require 'rock/bundle'
require 'vizkit'

include Orocos

BASE_DIR = File.expand_path('..', File.dirname(__FILE__))
ENV['PKG_CONFIG_PATH'] = "#{BASE_DIR}/build:#{ENV['PKG_CONFIG_PATH']}"

Bundles.initialize

Orocos.run 'trajectory_follower::Task' => 'tf' do |p|
#    Orocos.log_all_ports 
    tf = p.task 'tf'
    tf.apply_conf(['default'])

    if ARGV.size == 0 then
	log_replay = Orocos::Log::Replay.open( "item_follower.0.log", "item_planner.0.log" ) 
    else
	log_replay = Orocos::Log::Replay.open( ARGV[0]+"/item_velodyne.0.log" , ARGV[0]+"/item_planner.0.log" ) 
    end
    log_replay.global_planner.trajectory.connect_to( tf.trajectory, :type => :buffer, :size => 1 )
    log_replay.velodyne_slam.pose_samples.connect_to( tf.pose, :type => :buffer, :size => 1 )
    
    tf.configure
    tf.start

    Vizkit.display log_replay.velodyne_slam.pose_samples, :widget => Vizkit.default_loader.RigidBodyStateVisualization
    Vizkit.display log_replay.global_planner.trajectory
    
    Vizkit.display tf.currentCurvePointWp

    
    Vizkit.control log_replay
    Vizkit.exec

end

