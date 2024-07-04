 	#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Authors: 	Alperen Demirkol
#
# Date: 	26 May 2024
#
###########################

# Robot arm gripper communication ground station code.
# Takes joystick gripper command then sends UDP commands to gripper.

import socket
import rospy
from sensor_msgs.msg import Joy

class Murotuzo:
	def __init__(self):
		rospy.init_node("gripper_cmd_node")
		self.rate = rospy.Rate(10)

		print("Gripper Command Node Initialized")
		rospy.loginfo("Joystick teleoperation initialized")

		rospy.Subscriber("/joy", Joy, self.joy_cb)

		self.IP = "192.168.1.97" #Onboard computer IP
		self.PORT = 8887

		self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		self.conn = None
		self.addr = None

		self.gripper_cmd = None

		self.udp_send()

	def udp_send(self):
		while not rospy.is_shutdown():
			self.sent_str = "S"+str(self.gripper_cmd)+"F"
			print(self.sent_str)
			self.socket.sendto(self.sent_str.encode("utf-8"), (self.IP, self.PORT))
			self.rate.sleep()

	def joy_cb(self, data):
		self.rb = data.buttons[5] # RB button for gripper turbo mode
		self.back = data.buttons[6] # Back button for gripper open
		self.start = data.buttons[7] # Start button for gripper close
		self.close = data.buttons[4] # Close button for close pwm signals

		if self.rb:
			if self.back:
				self.gripper_cmd = "9"
			elif self.start:
				self.gripper_cmd = "0"
			else:
				self.gripper_cmd = "5"

		elif self.close:
			if self.back:
				if self.start:
					self.gripper_cmd = "2"

		else:
			if self.back:
				self.gripper_cmd = "7"
			elif self.start:
				self.gripper_cmd = "3"
			else:
				self.gripper_cmd = "5"

if __name__ == "__main__":
	try:
		Murotuzo()
	except KeyboardInterrupt:
		pass
