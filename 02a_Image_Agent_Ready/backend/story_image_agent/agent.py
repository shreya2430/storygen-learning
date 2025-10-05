"""Custom Image Agent that directly calls Imagen."""
import json
from typing import AsyncGenerator

from google.adk.agents import Agent, BaseAgent
from google.adk.runtime.events import Event
from google.adk.runtime.invocation_context import InvocationContext
from story_image_agent.imagen_tool import ImagenTool


class CustomImageAgent(BaseAgent):
  """A custom agent for image generation."""

  def __init__(self, imagen_tool: ImagenTool | None = None) -> None:
    super().__init__()
    self.imagen_tool = imagen_tool if imagen_tool else ImagenTool()

  @property
  def name(self) -> str:
    """The name of the agent."""
    return "custom_image_agent"

  async def _run_async_impl(
      self, ctx: InvocationContext
  ) -> AsyncGenerator[Event, None]:
    """Runs the agent and yields events."""
    user_message = ctx.user_content.parts[0].text

    try:
      # Try to parse the input as JSON
      input_data = json.loads(user_message)
      scene_description = input_data.get("scene_description", "")
      character_descriptions = input_data.get("character_descriptions", {})
    except json.JSONDecodeError:
      # Fallback to plain text if JSON parsing fails
      scene_description = user_message
      character_descriptions = {}

    # Construct the image prompt
    style_prefix = "Children's book cartoon illustration with bright vibrant colors, simple shapes, friendly characters."
    prompt = f"{style_prefix} {scene_description}"

    if character_descriptions:
      character_details = ", ".join(
          f"{name}: {desc}" for name, desc in character_descriptions.items()
      )
      prompt += f" Featuring characters: {character_details}."

    try:
      # Directly execute the ImagenTool
      image_result = await self.imagen_tool.run(prompt=prompt)

      # Store the successful result in the session state
      ctx.session.state["image_result"] = json.dumps({
          "status": "success",
          "images": image_result,
      })
      yield Event.from_agent(
          self.name, {"text": "Image generation successful."}
      )

    except Exception as e:
      # Store the error in the session state
      error_message = f"Image generation failed: {e}"
      ctx.session.state["image_result"] = json.dumps({
          "status": "error",
          "message": error_message,
      })
      yield Event.from_agent(self.name, {"text": error_message})
