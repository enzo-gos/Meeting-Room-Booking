import consumer from "channels/consumer";

document.addEventListener("turbo:load", function () {
  const room_id = $("[data-room-id]").attr("data-room-id");

  consumer.subscriptions.subscriptions.forEach((subscription) => {
    if (
      !room_id &&
      JSON.parse(subscription.identifier).channel === "RoomChannel"
    )
      consumer.subscriptions.remove(subscription);
  });

  if (room_id) {
    consumer.subscriptions.create(
      {
        channel: "RoomChannel",
        room_id: room_id,
      },
      {
        connected() {
          // Called when the subscription is ready for use on the server
          console.log(`Event created listening on room ${room_id}...`);
        },

        disconnected() {
          // Called when the subscription has been terminated by the server
        },

        received(data) {
          console.log(data);
          // Called when there's incoming data on the websocket for this channel
          document.dispatchEvent(
            new CustomEvent("eventCreated", { detail: data })
          );
        },
      }
    );
  }
});
