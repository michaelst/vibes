defmodule VibesWeb.Components.Live.FormModal do
  use VibesWeb, :html

  def render(assigns) do
    ~H"""
    <div class="relative z-10" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div
        :if={not is_nil(@editing)}
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
      >
      </div>

      <div :if={not is_nil(@editing)} class="fixed inset-0 z-10 w-screen overflow-y-auto">
        <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
          <div class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6">
            <div class="sm:flex sm:items-start">
              <div class="mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-gray-100 sm:mx-0 sm:h-10 sm:w-10">
                <.icon name="hero-link" class="h-6 w-6" />
              </div>
              <.form
                for={@form}
                class="w-full"
                phx-change="validate_submission_details"
                phx-submit="update_submission_details"
              >
                <div class="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left">
                  <label class="text-sm font-semibold leading-6 text-gray-900">
                    YouTube link
                  </label>
                  <div class="text-sm text-gray-600">
                    https://www.youtube.com/watch?v=xxx
                  </div>
                  <div class="mt-2">
                    <.input field={@form[:youtube_url]} />
                  </div>
                  <div class="mt-2">
                    <.input field={@form[:why]} label="Why did you add this song?" type="textarea" />
                  </div>
                </div>
                <div class="mt-5 sm:mt-4 sm:flex sm:pl-4">
                  <button
                    type="submit"
                    class="inline-flex w-full justify-center rounded-md bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 sm:w-auto"
                  >
                    Update
                  </button>
                  <button
                    type="button"
                    phx-click="close_modal"
                    class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:ml-3 sm:mt-0 sm:w-auto"
                  >
                    Cancel
                  </button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
