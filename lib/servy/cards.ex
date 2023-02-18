defmodule Servy.Cards do

  @ranks [ "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A" ]

  @suits [ "♣", "♦", "♥", "♠" ]

  def generate_deck do
    for rank <- @ranks, suit <- @suits do
      {rank, suit}
    end
  end

  def print_deck, do: Enum.each generate_deck(), & IO.inspect &1

  def deal_hand(amt \\ 13)
  def deal_hand(amt), do: Enum.take_random generate_deck(), amt

  def deal_hands(amt \\ 4, hand_size \\ 13)
  def deal_hands(amt, hand_size), do: for _ <- 1..amt, do: deal_hand(hand_size)
end
