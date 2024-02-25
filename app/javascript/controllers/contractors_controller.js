import { Controller } from "stimulus";

export default class extends Controller {
    edit(event) {
        event.preventDefault();
        const contractorId = event.currentTarget.dataset.contractorId;
        fetch(`/contractors/${contractorId}/edit`, { headers: { "Turbo-Frame": "contractor_form" } });
    }

    destroy(event) {
        event.preventDefault();
        const contractorId = event.currentTarget.dataset.contractorId;
        if (confirm("Are you sure?")) {
            fetch(`/contractors/${contractorId}`, { method: "DELETE", headers: { "Turbo-Frame": "contractor_form" } });
        }
    }
}