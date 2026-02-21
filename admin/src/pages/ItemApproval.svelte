<script>
	import Main from "../components/templates/Main.svelte";
	import Loader from "../components/misc/Loader.svelte";
	import request from "../lib/request";
	import { onMount } from "svelte";

	let requests = null;
	let loading = true;
	let error = null;

	let showModal = false;
	let selectedRequest = null;
	let editName = "";
	let editRobux = 0;
	let editTix = 0;
	let editCreatorId = 0;
	let editItemType = "Normal";
	let editStock = 0;
	let editForSale = true;
	let editVisible = true;
	let submitting = false;

	const loadRequests = async () => {
		loading = true;
		try {
			const res = await request.request({
				url: "/apisite/request-item/v1/list",
				method: "GET",
				baseURL: "/",
			});
			requests = res.data;
		} catch (e) {
			error = e.message;
		} finally {
			loading = false;
		}
	};

	onMount(() => {
		loadRequests();
	});

	const openApproveModal = (req) => {
		selectedRequest = req;
		editName = req.name;
		editRobux = req.robux_price || req.robuxPrice || 0;
		editTix = req.tix_price || req.tixPrice || 0;
		editCreatorId = req.type === "Roblox" ? 1 : req.submitter_id || req.submitterId || 0;
		editItemType = req.is_limited || req.isLimited ? "LimitedUnique" : "Normal";
		editStock = req.stock;
		editForSale = true;
		editVisible = true;
		showModal = true;
	};

	const closeModal = () => {
		showModal = false;
		selectedRequest = null;
	};

	const handleApprove = async () => {
		submitting = true;
		try {
			await request.request({
				url: "/apisite/request-item/v1/approve",
				method: "POST",
				baseURL: "/",
				data: {
					action: "approve",
					id: selectedRequest.id,
					name: editName,
					robuxPrice: editRobux,
					tixPrice: editTix,
					creatorId: editCreatorId,
					itemLimitedType: editItemType,
					stock: editStock,
					forSale: editForSale,
					visible: editVisible,
				},
			});

			closeModal();
			loadRequests();
		} catch (e) {
			alert(e.message);
		} finally {
			submitting = false;
		}
	};

	const handleDecline = async (req) => {
		if (!confirm(`Are you sure you want to decline "${req.name}"?`)) return;

		try {
			await request.request({
				url: "/apisite/request-item/v1/approve",
				method: "POST",
				baseURL: "/",
				data: {
					action: "decline",
					id: req.id,
				},
			});

			loadRequests();
		} catch (e) {
			alert(e.message);
		}
	};
</script>

<svelte:head>
	<title>Item Approval</title>
</svelte:head>

<Main>
	<div class="row">
		<div class="col-12">
			<h1>Item Request Approval</h1>
			<button class="btn btn-secondary mb-3" on:click={loadRequests}>Refresh</button>

			{#if loading}
				<Loader />
			{:else if error}
				<p class="text-danger">{error}</p>
			{:else if !requests || requests.length === 0}
				<p>No pending requests.</p>
			{:else}
				<div class="table-responsive">
					<table class="table table-striped">
						<thead>
							<tr>
								<th>ID</th>
								<th>Type</th>
								<th>Info</th>
								<th>Pricing</th>
								<th>Assets</th>
								<th>Actions</th>
							</tr>
						</thead>
						<tbody>
							{#each requests as req}
								<tr>
									<td>{req.id}</td>
									<td>{req.type}</td>
									<td>
										<strong>{req.name}</strong><br />
										<small>{req.description}</small><br />
										<small>By ID: {req.submitter_id || req.submitterId || "Guest"}</small>
									</td>
									<td>
										R$ {req.robux_price || req.robuxPrice || 0} | Tix {req.tix_price || req.tixPrice || 0}<br />
										{#if req.is_limited || req.isLimited}
											<span class="badge bg-warning text-dark">Limited ({req.stock})</span>
										{/if}
									</td>
									<td>
										{#if req.type === "Roblox"}
											<a href={req.asset_url || req.assetUrl} target="_blank">Target Asset</a>
										{:else}
											<a href={req.rbxm_path || req.rbxmPath} target="_blank">RBXM</a> |
											<a href={req.obj_path || req.objPath} target="_blank">OBJ</a>
										{/if}
									</td>
									<td>
										<button class="btn btn-success btn-sm me-2" on:click={() => openApproveModal(req)}>Approve</button>
										<button class="btn btn-danger btn-sm" on:click={() => handleDecline(req)}>Decline</button>
									</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			{/if}
		</div>
	</div>

	{#if showModal}
		<div class="custom-modal-backdrop">
			<div class="custom-modal-content">
				<h3>Approve Item</h3>
				<div class="mb-3">
					<label class="form-label">Name</label>
					<input type="text" class="form-control" bind:value={editName} />
				</div>
				<div class="row">
					<div class="col-6 mb-3">
						<label class="form-label">Robux</label>
						<input type="number" class="form-control" bind:value={editRobux} />
					</div>
					<div class="col-6 mb-3">
						<label class="form-label">Tix</label>
						<input type="number" class="form-control" bind:value={editTix} />
					</div>
				</div>
				<div class="mb-3">
					<label class="form-label">Creator ID (User ID)</label>
					<input type="number" class="form-control" bind:value={editCreatorId} />
					<div class="form-text">The user who will own/create this item. Defaults to submitter.</div>
				</div>
				<div class="mb-3 form-check">
					<input type="checkbox" class="form-check-input" id="editVisible" bind:checked={editVisible} />
					<label class="form-check-label" for="editVisible">Visible</label>
				</div>
				<div class="mb-3 form-check">
					<input type="checkbox" class="form-check-input" id="editForSale" bind:checked={editForSale} />
					<label class="form-check-label" for="editForSale">For Sale</label>
				</div>
				<div class="mb-3">
					<label class="form-label">Item Type</label>
					<select class="form-select" bind:value={editItemType}>
						<option value="Normal">Normal</option>
						<option value="Limited">Limited</option>
						<option value="LimitedUnique">Limited Unique</option>
					</select>
				</div>
				{#if editItemType === "LimitedUnique"}
					<div class="mb-3">
						<label class="form-label">Stock</label>
						<input type="number" class="form-control" bind:value={editStock} />
					</div>
				{/if}

				<div class="text-end">
					<button class="btn btn-secondary me-2" on:click={closeModal}>Cancel</button>
					<button class="btn btn-success" on:click={handleApprove} disabled={submitting}>
						{submitting ? "Processing..." : "Confirm Approval"}
					</button>
				</div>
			</div>
		</div>
	{/if}
</Main>

<style>
	.custom-modal-backdrop {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background: rgba(0, 0, 0, 0.5);
		display: flex;
		justify-content: center;
		align-items: center;
		z-index: 1000;
	}
	.custom-modal-content {
		background: white;
		padding: 20px;
		border-radius: 5px;
		width: 500px;
		max-width: 90%;
	}
	.img-preview {
		max-width: 100px;
		max-height: 100px;
	}
</style>
