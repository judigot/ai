# Workstation setup and teardown

Read this when preparing infrastructure or operating the EC2 desktop.

## 1. Prepare the plan

Record the account, region, AMI owner/ID, architecture, instance type, disk size,
network path, IAM role, artifact bucket/prefix, retention, and session expiry.
Use a Canonical-published Ubuntu image; resolve its ID in the selected region.
Include compute, EBS, public IPv4, data transfer, and any NAT/endpoint charges
in the estimate. Obtain current regional prices; do not copy old price figures.

Use a scoped instance role for SSM and the chosen S3 prefix. Do not inject
long-lived AWS keys. Tag only the resources created for this workspace with a
unique workspace ID. Review a Terraform plan for unrelated changes before apply.

Define expiry behavior before launch: a grace period for saving, followed by the
user-authorized stop or termination policy. Explain that hard expiry can discard
unsaved data. A shutdown hook alone is not a reliable backup mechanism.

## 2. Bootstrap reproducibly

Keep Terraform/cloud-init and application setup in the designated infrastructure
or application repo. Install the required runtime/package manager, git, gh,
OpenCode, Xfce/X11, DCV, browser dependencies, and optional recorder. Respect the
application's lockfile and existing package manager. Make repeated bootstrap runs
safe: reuse installed packages and named resources instead of creating duplicates.

Fetch current DCV installation instructions for the chosen Ubuntu release and
CPU architecture. Verify package signatures where supplied. Treat Ubuntu's
documented GNOME setup as distinct from a validated Xfce setup: do not blindly
install `ubuntu-desktop`, introduce LightDM, or claim AWS documents Xfce-specific
steps when it does not. Select a supported DCV session type and configure its
desktop startup for Xfce, then test it. If compatibility cannot be established,
report the exact failure and propose a documented alternative.

Use an ordinary development user for the browser/agent. Avoid disabling Chromium
sandboxing to compensate for running it as root. AMIs may contain tools, but must
not contain login tokens, repository secrets, or personal browser profiles.

## 3. Establish private access

Keep DCV, OpenCode, RDP/VNC, and browser-debugging endpoints off the unrestricted
public internet. Use the existing VPN, SSM forwarding, or authenticated TLS
gateway. For SSM, verify agent health, instance role, endpoint connectivity, and
the local Session Manager plugin. A browser-only client needs a reachable private
gateway or VPN path; it cannot run a local SSM tunnel by itself.

Configure DCV TLS and authentication. Verify the installed version's client
support for the user's device. For OpenCode web access, configure its documented
server password and HTTPS/private access before exposing it. Browser-control
ports such as Chromium's debugging port must remain local/private.

Check that reconnecting to the desktop returns to the same session. Do not run a
second desktop solely for the recorder: it might capture an empty screen.

## 4. Align the agent and browser with the desktop

Start OpenCode from a terminal inside the chosen desktop for the first test.
Child browser/recorder processes should inherit that session's `DISPLAY`, X11
authorization, and other required environment. For a background service, explicitly
configure the same user's session environment after it exists. Never assume
`DISPLAY=:0`; discover the actual display. Do not use `xhost +` to bypass access.

If project services run in containers, decide where Chromium runs. Simplest:
run the browser/agent on the EC2 host and publish the app's port to host loopback.
Remember that `localhost` inside a container refers to that container.

Verify all three together: the user sees the browser, the agent can click it,
and the recorder captures that same action. A separate `xvfb-run` display can
hide the test from the user; do not use it for the observed demonstration unless
that exact display is also streamed.

## 5. Save incrementally

After each completed journey, close browser contexts and finalize video files.
Upload evidence into a private prefix organized by workspace, task, and run ID.
Keep an inventory containing filenames, byte sizes, checksums, test results,
commit SHA, and tool versions. Verify uploaded object metadata/checksums; do not
use an S3 ETag as a universal content checksum. Open a retrieved screenshot/video
and trace to confirm usability. Keep access limited and apply the agreed retention.

Push intended code changes to the correct branch. Review for secrets before
committing. Save required agent history separately with protected credentials
excluded. Do not assume restoring source code restores the conversation.

## 6. Teardown gates

Before normal termination, verify:

1. All relevant browser contexts/recorders have closed cleanly.
2. Durable artifacts exist and are readable.
3. Intended code is pushed; uncommitted work is explicitly preserved.
4. Requested conversation history is saved.
5. The exact workspace instance and owned disposable resources are identified.

If upload or code preservation fails, do not terminate as a routine success step.
Retry once after correcting a diagnosed cause, then report the blocker and apply
the pre-agreed expiry/recovery policy. Do not loop indefinitely or silently cancel
a cost cap. For Spot, upload throughout the session; interruption notices are not
a guaranteed opportunity to complete all backups.

Terminate only within the user's authorization. Root EBS deletion must be an
explicit reviewed setting; retained data volumes require a separate decision.
Never delete a shared S3 bucket, shared VPC, unrelated disk, or infrastructure
state. Verify the instance reaches `terminated` and report retained billable
resources. Stopping compute still leaves storage charges; terminating an instance
does not automatically remove every associated AWS resource.

Useful sources:

- [Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [EC2 termination](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html)
- [Spot interruptions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html)
