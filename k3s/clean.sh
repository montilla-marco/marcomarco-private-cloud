Clean up your cluster
Open a new terminal window (on the host), and then use the multipass stop command to stop your nodes:

 multipass stop k3s-master k3s-worker-1 k3s-worker-2
Delete your instances with:

 multipass delete k3s-master k3s-worker-1 k3s-worker-2
Permanently delete your instances by entering:

 multipass purge
Use the multipass list command to verify that the instances were deleted:

 multipass list
 No instances found.
