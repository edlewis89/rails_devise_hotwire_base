import { Controller } from "stimulus";
import { turbo_stream } from "@hotwired/turbo-rails";

export default class extends Controller {
    static targets = ["input"];

    connect() {
        this.inputTarget.addEventListener("input", this.search.bind(this));
    }

    search(event) {
        const searchTerm = event.target.value;
        if (searchTerm.length >= 2) {
            fetch(`/contractors/autocomplete?term=${searchTerm}`)
                .then(response => response.text())
                .then(data => {
                    const turboStreamElement = document.createElement('div');
                    turboStreamElement.innerHTML = data;
                    turbo_stream.render(turboStreamElement);
                });
        }
    }
}

// import { Controller } from "stimulus";
//
// export default class extends Controller {
//     // edit(event) {
//     //     event.preventDefault();
//     //     const contractorId = event.currentTarget.dataset.contractorId;
//     //     fetch(`/contractors/${contractorId}/edit`, { headers: { "Turbo-Frame": "contractor_form" } });
//     // }
//     //
//     // destroy(event) {
//     //     event.preventDefault();
//     //     const contractorId = event.currentTarget.dataset.contractorId;
//     //     if (confirm("Are you sure?")) {
//     //         fetch(`/contractors/${contractorId}`, { method: "DELETE", headers: { "Turbo-Frame": "contractor_form" } });
//     //     }
//     // }
//
//     connect() {
//         const autocompleteField = document.querySelector('#contractor_name_field');
//         autocompleteField.addEventListener('turbo:submit-end', this.handleTurboStreamResponse.bind(this));
//     }
//
//     handleTurboStreamResponse(event) {
//         const [stream] = event.detail.fetchResponse.template.extract();
//         if (stream.target == 'contractor_list') {
//             const suggestions = stream.content;
//             const autocompleteField = document.querySelector('#contractor_name_field');
//             autocompleteField.innerHTML = suggestions;
//         }
//     }
// }